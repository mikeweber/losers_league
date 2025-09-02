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
FactoryBot.define do
  factory :week do
    season { nil }
    week { 1 }
  end
end
