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

  class << self
    def preload_consts
      return false if defined?(@consts_preloaded)

      Team.all.each do |team|
        const_set(team.initials, team)
      end

      @consts_preloaded = true
    end
  end
end
