# == Schema Information
#
# Table name: teams
#
#  id         :bigint           not null, primary key
#  initials   :string
#  logo_url   :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Team < ApplicationRecord
  has_many :picks
end
