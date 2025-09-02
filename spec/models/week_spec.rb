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
require 'rails_helper'

RSpec.describe Week, type: :model do
  let(:user) { FactoryBot.create(:user, email: "liamg@gmail.com") }
  let(:user2) { FactoryBot.create(:user, email: "gary@gmail.com") }

  let(:season) { FactoryBot.create(:season, year: 2025) }
  let(:week1) { FactoryBot.create(:week, week: 1, season:, starts_at: Time.new(2025, 9, 4)) }

  let(:team1) { FactoryBot.create(:team, name: "Packers", initials: "GB") }
  let(:team2) { FactoryBot.create(:team, name: "Vikings", initials: "MN") }
  let(:team3) { FactoryBot.create(:team, name: "Bears", initials: "CHI") }
  let(:team4) { FactoryBot.create(:team, name: "Lions", initials: "DET") }

  let!(:week1_game1) { FactoryBot.create(:matchup, week: week1, home: team1, away: team2, home_score: 17, away_score: 16, kickoff: Time.new(2025, 9, 4, 12)) }
  let!(:week1_game2) { FactoryBot.create(:matchup, week: week1, home: team3, away: team4, home_score: 11, away_score: 16, kickoff: Time.new(2025, 9, 4, 15)) }

  describe "#picks_locked?" do
    it "returns true when the first kick off is in the past" do
      Timecop.freeze(Time.new(2025, 9, 4, 12, 1)) do
        expect(week1).to be_picks_locked
      end
    end

    it "returns false when the first kick off is in the future" do
      Timecop.freeze(Time.new(2025, 9, 4, 11, 59)) do
        expect(week1).not_to be_picks_locked
      end
    end
  end
end
