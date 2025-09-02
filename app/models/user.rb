# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class User < ApplicationRecord
  has_many :picks

  def strikes_for(year:)
    picked_matchups_for(year:).select do |matchup, pick|
      next unless matchup.final?

      if pick.team == matchup.home
        matchup.home_won?
      else
        matchup.away_won?
      end
    end
  end

  def picked_matchups_for(year:)
    picks_for(year:).flat_map do |pick|
      [pick.week.matchups.select { |matchup| [matchup.home, matchup.away].include?(pick.team) }, pick]
    end
  end

  def picks_for(year:)
    picks.joins(week: :season).where(season: { year: })
  end
end
