# == Schema Information
#
# Table name: matchups
#
#  id         :bigint           not null, primary key
#  away_score :integer
#  home_score :integer
#  kickoff    :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  away_id    :bigint           not null
#  home_id    :bigint           not null
#  week_id    :bigint           not null
#
# Indexes
#
#  index_matchups_on_away_id  (away_id)
#  index_matchups_on_home_id  (home_id)
#  index_matchups_on_week_id  (week_id)
#
# Foreign Keys
#
#  fk_rails_...  (away_id => teams.id)
#  fk_rails_...  (home_id => teams.id)
#  fk_rails_...  (week_id => weeks.id)
#
class Matchup < ApplicationRecord
  belongs_to :week
  belongs_to :home, class_name: "Team"
  belongs_to :away, class_name: "Team"

  def final?
    away_score.present? && home_score.present?
  end

  def home_won?
    return false if home_score.nil? || away_score.nil?

    home_score > away_score
  end

  def away_won?
    return false if home_score.nil? || away_score.nil?

    away_score > home_score
  end

  def missing_score?(now = Time.now)
    !final? && kickoff && kickoff + 3.hours < now
  end
end
