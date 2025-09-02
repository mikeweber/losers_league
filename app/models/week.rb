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
    def current_week
      joins(:season, :matchups)
        .where(seasons: { year: Season.maximum(:year) })
        .where(matchups: { home_score: nil })
        .maximum(:week)
    end
  end

  def picks_locked?
    matchups.any? { _1.kickoff.past? }
  end
end
