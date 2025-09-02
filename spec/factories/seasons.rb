# == Schema Information
#
# Table name: seasons
#
#  id         :bigint           not null, primary key
#  year       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :season do
    year { 2025 }
  end
end
