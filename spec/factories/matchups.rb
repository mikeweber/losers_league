# == Schema Information
#
# Table name: matchups
#
#  id         :bigint           not null, primary key
#  away_score :integer
#  home_score :integer
#  kickoff    :datetime         not null
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
FactoryBot.define do
  factory :matchup do
    week { nil }
    home { nil }
    away { nil }
    home_score { nil }
    away_score { nil }
  end
end
