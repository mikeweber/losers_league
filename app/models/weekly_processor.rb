class WeeklyProcessor
  attr_reader :week, :statuses

  def initialize(week:, statuses:)
    @week = week
    @statuses = statuses
  end

  def process!(skip_save: false)
    raise "Cannot process week yet!" unless can_process?

    process_picks!

    mark_champions!

    roll_back_last_eliminated_players!

    finalize_week!(skip_save:)

    statuses
  end

  def rebuy!(user_id)
    statuses[user_id].rebuy!
    mark_champions!
  end

  def can_process?
    week.games_complete?
  end

  private

  def process_picks!
    week.picks.each do |pick|
      status = statuses[pick.user_id]
      next unless status.can_process_week?(week.week)

      # They didn't re-buy during their re-buy window; Eliminate them.
      status.eliminated! if status.can_rebuy?

      process_pick!(status:, pick:)
    end
  end

  def process_pick!(status:, pick:)
    if pick.correct?
      status.mark_win!
    elsif pick.incorrect?
      status.mark_loss!
    else
      raise "huh?"
    end
  end

  def mark_champions!
    return unless still_playing.size == 1 || week.final_week?

    still_playing.each do |status|
      next unless status.can_process_week?(week.week)

      status.champion!
    end
  end

  def roll_back_last_eliminated_players!
    return unless still_playing.size == 0

    # Find the players that would have been eliminated this week, and mark them as still playing
    statuses.values.each do |status|
      next unless status.can_process_week?(week.week) && status.eliminated? && !status.status_was_eliminated?

      status.revert_status!
    end
  end

  def finalize_week!(skip_save:)
    statuses.values.each do |status|
      next unless status.can_process_week?(week.week)

      status.save_week!(week.week, skip_save:)
    end
  end

  def still_playing
    statuses.filter_map { |_, status| status unless status.eliminated? }
  end
end
