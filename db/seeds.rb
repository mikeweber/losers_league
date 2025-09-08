# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

s25 = Season.find_or_create_by!(year: 2025)

first_thursday = Time.new(2025, 9, 4)
18.times do |i|
  s25.weeks
    .create_with(starts_at: first_thursday + i.weeks)
    .find_or_create_by!(week: i + 1)
end

[
  ["Arizona Cardinals", "ARI"],
  ["Atlanta Falcons", "ATL"],
  ["Baltimore Ravens", "BAL"],
  ["Buffalo Bills", "BUF"],
  ["Carolina Panthers", "CAR"],
  ["Chicago Bears", "CHI"],
  ["Cincinnati Bengals", "CIN"],
  ["Cleveland Browns", "CLE"],
  ["Dallas Cowboys", "DAL"],
  ["Denver Broncos", "DEN"],
  ["Detroit Lions", "DET"],
  ["Green Bay Packers", "GB"],
  ["Houston Texans", "HOU"],
  ["Indianapolis Colts", "IND"],
  ["Jacksonville Jaguars", "JAX"],
  ["Kansas City Chiefs", "KC"],
  ["Las Vegas Raiders", "LV"],
  ["Los Angeles Chargers", "LAC"],
  ["Los Angeles Rams", "LAR"],
  ["Miami Dolphins", "MIA"],
  ["Minnesota Vikings", "MIN"],
  ["New England Patriots", "NE"],
  ["New Orleans Saints", "NO"],
  ["New York Giants", "NYG"],
  ["New York Jets", "NYJ"],
  ["Philadelphia Eagles", "PHI"],
  ["Pittsburgh Steelers", "PIT"],
  ["San Francisco 49ers", "SF"],
  ["Seattle Seahawks", "SEA"],
  ["Tampa Bay Buccaneers", "TB"],
  ["Tennessee Titans", "TEN"],
  ["Washington Commanders", "WSH"],
].each do |name, initials|
  Team.find_or_create_by!(name:, initials:)
end
