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

  def correct_picks_for(season_id:)
    picked_matchups_for(season_id:).select do |_week, matchup_and_pick|
      matchup, pick = matchup_and_pick.values_at(:matchup, :pick)
      next unless matchup.final?

      if pick.team == matchup.home
        matchup.away_won?
      else
        matchup.home_won?
      end
    end
  end

  def strikes_for(season_id:)
    picked_matchups_for(season_id:).select do |_week, matchup_and_pick|
      matchup, pick = matchup_and_pick.values_at(:matchup, :pick)
      next unless matchup.final?

      if pick.team == matchup.home
        matchup.home_won?
      else
        matchup.away_won?
      end
    end
  end

  def used_teams(season_id:)
    picked_matchups_for(season_id:).filter_map do |_week, matchup_and_pick|
      matchup, pick = matchup_and_pick.values_at(:matchup, :pick)
      next unless matchup.final?

      pick.team
    end
  end

  def picked_matchups_for(season_id:)
    picks_for(season_id:).to_h do |pick|
      [pick.week.week, { matchup: pick.week.matchups.detect { |matchup| [matchup.home, matchup.away].include?(pick.team) }, pick: }]
    end
  end

  def picks_for(season_id:)
    @picks_for ||= {}
    @picks_for[season_id] ||= picks.joins(:week).where(weeks: { season_id: season_id })
  end

  private

  def assign_secret_identifier
    self.secret_identifier ||= SecureRandom.hex(8)
  end
end
