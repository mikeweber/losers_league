# == Schema Information
#
# Table name: picks
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  team_id    :bigint           not null
#  user_id    :bigint           not null
#  week_id    :bigint           not null
#
# Indexes
#
#  index_picks_on_team_id  (team_id)
#  index_picks_on_user_id  (user_id)
#  index_picks_on_week_id  (week_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (week_id => weeks.id)
#
class Pick < ApplicationRecord
  belongs_to :user
  belongs_to :week
  belongs_to :team

  def correct?
    return false if matchup.nil?

    picked_home? && matchup.away_won? || picked_away? && matchup.home_won?
  end

  def incorrect?
    return false if matchup.nil?

    picked_home? && matchup.home_won? || picked_away? && matchup.away_won?
  end

  def picked_home?
    matchup.home_id == team_id
  end

  def picked_away?
    matchup.away_id == team_id
  end

  def matchup
    @matchup ||= week.matchups.detect { |matchup| [matchup.home_id, matchup.away_id].include?(team_id) }
  end
end
