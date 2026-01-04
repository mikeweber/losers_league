# == Schema Information
#
# Table name: weeks
#
#  id         :bigint           not null, primary key
#  starts_at  :datetime         not null
#  week       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  season_id  :bigint           not null
#
# Indexes
#
#  index_weeks_on_season_id  (season_id)
#
# Foreign Keys
#
#  fk_rails_...  (season_id => seasons.id)
#
class Week < ApplicationRecord
  belongs_to :season

  has_many :matchups
  has_many :picks

  class << self
    def current_week(now = Time.now)
      where(starts_at: ..(now + 2.days)).maximum(:week) || 1
    end
  end

  def picks_locked?(now = Time.now)
    matchups.any? { _1.kickoff && _1.kickoff < now }
  end

  def games_complete?
    picks.all? { _1.matchup.final? }
  end

  def final_week?
    week == 18
  end
end
