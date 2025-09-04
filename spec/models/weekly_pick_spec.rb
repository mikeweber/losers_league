require "rails_helper"

RSpec.describe WeeklyPick do
  let(:user) { FactoryBot.create(:user, email: "liamg@gmail.com") }
  let(:user2) { FactoryBot.create(:user, email: "gary@gmail.com") }

  let(:season) { FactoryBot.create(:season, year: 2025) }
  let(:init_start_at) { Time.new(2025, 9, 4) }
  let(:week1) { FactoryBot.create(:week, week: 1, season:, starts_at: init_start_at + 0.weeks) }
  let(:week2) { FactoryBot.create(:week, week: 2, season:, starts_at: init_start_at + 1.weeks) }
  let(:week3) { FactoryBot.create(:week, week: 3, season:, starts_at: init_start_at + 2.weeks) }

  let(:team1) { FactoryBot.create(:team, name: "Packers", initials: "GB") }
  let(:team2) { FactoryBot.create(:team, name: "Vikings", initials: "MN") }
  let(:team3) { FactoryBot.create(:team, name: "Bears", initials: "CHI") }
  let(:team4) { FactoryBot.create(:team, name: "Lions", initials: "DET") }

  let!(:week1_game1) { FactoryBot.create(:matchup, week: week1, home: team1, away: team2, home_score: 17, away_score: 16, kickoff: Time.new(2025, 9, 4, 12)) }
  let!(:week1_game2) { FactoryBot.create(:matchup, week: week1, home: team3, away: team4, home_score: 11, away_score: 16, kickoff: Time.new(2025, 9, 4, 15)) }

  let!(:week2_game1) { FactoryBot.create(:matchup, week: week2, home: team1, away: team3, kickoff: Time.new(2025, 9, 11, 12)) }
  let!(:week2_game2) { FactoryBot.create(:matchup, week: week2, home: team2, away: team4, kickoff: Time.new(2025, 9, 11, 15)) }

  let!(:week3_game1) { FactoryBot.create(:matchup, week: week2, home: team1, away: team4, kickoff: Time.new(2025, 9, 18, 12)) }
  let!(:week3_game2) { FactoryBot.create(:matchup, week: week2, home: team2, away: team3, kickoff: Time.new(2025, 9, 18, 15)) }

  context "when the week has started" do
    around do |example|
      Timecop.freeze(Time.new(2025, 9, 4, 12, 1)) { example.run }
    end

    it "does not allow the user to make a pick" do
      weekly_pick = described_class.new(user:, week: week1)
      expect(weekly_pick.pick_loser!(team3)).to be(false)
      expect(weekly_pick.errors[:week]).to include("is closed")
    end
  end

  context "when the week is coming up" do
    let!(:week1_team3_pick) { FactoryBot.create(:pick, user:, week: week1, team: team3) }
    around do |example|
      Timecop.freeze(Time.new(2025, 9, 11, 11, 59)) { example.run }
    end

    it "allows the user to make a pick" do
      expect { described_class.new(user:, week: week2).pick_loser!(team2) }.to change { Pick.count }
      expect(user.picks.map { |pick| pick.team.initials }).to eq(["CHI", "MN"])
    end

    it "does not allow the user to repeat a previous pick" do
      weekly_pick2 = described_class.new(user:, week: week2)
      expect { weekly_pick2.pick_loser!(team3) }.not_to change { Pick.count }
      expect(weekly_pick2.errors[:team]).to include("has been used already")
    end

    it "clears out any future picks that would cause a duplicate" do
      FactoryBot.create(:pick, user:, week: week3, team: team1)
      expect(user.picks.map { |pick| { team: pick.team.initials, week: pick.week.week } }).to match_array([{ team: "CHI", week: 1 }, { team: "GB", week: 3 }])

      expect { described_class.new(user:, week: week2).pick_loser!(team1) }.not_to change { Pick.count }

      expect(user.picks.reload.map { |pick| { team: pick.team.initials, week: pick.week.week } }).to match_array([{ team: "CHI", week: 1 }, { team: "GB", week: 2 }])
    end

    it "can change a team for a given week" do
      FactoryBot.create(:pick, user:, week: week2, team: team1)
      expect(user.picks.map { |pick| { team: pick.team.initials, week: pick.week.week } }).to match_array([{ team: "CHI", week: 1 }, { team: "GB", week: 2 }])

      expect { described_class.new(user:, week: week2).pick_loser!(team2) }.not_to change { Pick.count }

      expect(user.picks.reload.map { |pick| { team: pick.team.initials, week: pick.week.week } }).to match_array([{ team: "CHI", week: 1 }, { team: "MN", week: 2 }])
    end

    it "leaves other future picks in place" do
      FactoryBot.create(:pick, user:, week: week3, team: team1)
      expect(user.picks.map { |pick| { team: pick.team.initials, week: pick.week.week } }).to match_array([{ team: "CHI", week: 1 }, { team: "GB", week: 3 }])

      expect { described_class.new(user:, week: week2).pick_loser!(team2) }.to change { Pick.count }

      expect(user.picks.reload.map { |pick| { team: pick.team.initials, week: pick.week.week } }).to match_array([{ team: "CHI", week: 1 }, { team: "MN", week: 2 }, { team: "GB", week: 3 }])
    end
  end
end
