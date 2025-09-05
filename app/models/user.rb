# == Schema Information
#
# Table name: users
#
#  id                :bigint           not null, primary key
#  email             :string           not null
#  name              :string           not null
#  secret_identifier :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class User < ApplicationRecord
  has_many :picks

  before_create :assign_secret_identifier

  def correct_picks_for(year:)
    picked_matchups_for(year:).select do |_week, matchup_and_pick|
      matchup, pick = matchup_and_pick.values_at(:matchup, :pick)
      next unless matchup.final?

      if pick.team == matchup.home
        matchup.away_won?
      else
        matchup.home_won?
      end
    end
  end

  def strikes_for(year:)
    picked_matchups_for(year:).select do |_week, matchup_and_pick|
      matchup, pick = matchup_and_pick.values_at(:matchup, :pick)
      next unless matchup.final?

      if pick.team == matchup.home
        matchup.home_won?
      else
        matchup.away_won?
      end
    end
  end

  def used_teams(year:)
    picked_matchups_for(year:).filter_map do |_week, matchup_and_pick|
      matchup, pick = matchup_and_pick.values_at(:matchup, :pick)
      next unless matchup.final?

      pick.team
    end
  end

  def picked_matchups_for(year:)
    picks_for(year:).to_h do |pick|
      [pick.week.week, { matchup: pick.week.matchups.detect { |matchup| [matchup.home, matchup.away].include?(pick.team) }, pick: }]
    end
  end

  def picks_for(year:)
    @picks_for ||= {}
    @picks_for[year] ||= picks.joins(week: :season).where(season: { year: })
  end

  private

  def assign_secret_identifier
    self.secret_identifier ||= SecureRandom.hex(8)
  end
end
