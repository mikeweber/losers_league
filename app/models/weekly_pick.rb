require "active_model"

class WeeklyPick
  include ActiveModel::Validations

  attr_reader :user, :week, :losing_team, :now

  def initialize(user:, week:, losing_team: nil, now: Time.now)
    @user = user
    @week = week
    @losing_team = losing_team
    @now = now
  end

  def pick_loser!(losing_team)
    if week_closed?
      errors.add(:week, "is closed")
      return false
    end
    if team_picked_previously?(losing_team)
      errors.add(:team, "has been used already")
      return false
    end

    Pick.transaction do
      remove_future_picks!(losing_team)
      if (pick = week.picks.find_by(user:))
        pick.update!(team: losing_team)
      else
        week.picks.create!(user:, team: losing_team)
      end
    end
    @losing_team = losing_team
    true
  end

  def year
    week.season.year
  end

  def week_num
    week.week
  end

  def loser_id
    @losing_team&.id
  end

  private

  def week_closed?
    week.picks_locked?(now)
  end

  def team_picked_previously?(team)
    previous_picks.any? { |pick| pick.team == team }
  end

  def previous_picks
    season_picks.select { _1.week.week < week.week }
  end

  def remove_future_picks!(team)
    season_picks.select { _1.week.week >= week.week && _1.team == team }.each(&:destroy!)
  end

  def season_picks
    @season_picks ||= user.picks.joins(:week).preload(:week, :team).where(weeks: { season_id: week.season_id })
  end
end
