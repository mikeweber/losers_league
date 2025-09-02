# == Schema Information
#
# Table name: teams
#
#  id         :bigint           not null, primary key
#  initials   :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :team do
    name { "MyString" }
    initials { "MyString" }
  end
end
