# == Schema Information
#
# Table name: season_statuses
#
#  id             :bigint           not null, primary key
#  losses         :integer          default(0), not null
#  processed_week :integer          default(0), not null
#  status         :string           default("playing"), not null
#  took_rebuy     :boolean          default(FALSE), not null
#  wins           :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  season_id      :bigint           not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_season_statuses_on_season_id              (season_id)
#  index_season_statuses_on_user_id                (user_id)
#  index_season_statuses_on_user_id_and_season_id  (user_id,season_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (season_id => seasons.id)
#  fk_rails_...  (user_id => users.id)
#
class SeasonStatus < ApplicationRecord
  belongs_to :user
  belongs_to :season

  STATUSES = [
    PLAYING = :playing,
    CAN_REBUY = :can_rebuy,
    ELIMINATED = :eliminated,
    CHAMPION = :champion,
  ]

  STATUSES.each do |status_name|
    define_method("#{status_name}?") do
      status == status_name
    end

    define_method("status_was_#{status_name}?") do
      @status_was == status_name
    end

    define_method("#{status_name}!") do
      custom_method = "transition_to_#{status_name}_allowed?"
      raise invalid_transition! if respond_to?(custom_method) && !send(custom_method)

      self.status = status_name
    end
  end

  def can_process_week?(week_num)
    processed_week.to_i + 1 == week_num
  end

  def revert_status!
    self.status = @status_was = PLAYING
  end

  def picks
    @picks ||= user.picks.where(week: season.weeks)
  end

  def rebuy!
    raise "Can only rebuy once!" if took_rebuy?

    self.playing!
    self.took_rebuy = true
  end

  def mark_loss!
    self.losses += 1

    if playing? && losses == loss_limit
      if losses == 3
        can_rebuy!
      else
        eliminated!
      end
    end

    losses
  end

  def mark_win!
    self.wins += 1
    wins
  end

  def loss_limit
    took_rebuy? ? 4 : 3
  end

  def save_week!(week_num, skip_save: false)
    @status_was = status
    self.processed_week = week_num
    save! unless skip_save
  end

  private

  def transition_to_champion_allowed?
    !eliminated?
  end

  def status=(new_status)
    status_symbol = new_status&.to_sym
    unrecognized_state! unless valid_state?(status_symbol)

    @status_was = status
    self[:status] = status_symbol
  end

  def status
    self[:status]&.to_sym
  end

  def valid_state?(new_status)
    STATUSES.include?(new_status)
  end

  def unrecognized_state!
    raise "Unrecognized state!"
  end

  def invalid_transition!(new_status)
    raise "Cannot transition from #{status.inspect} to #{new_status.inspect}"
  end
end
