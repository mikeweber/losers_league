require "csv"

class ScheduleImporter
  class << self
    def import_dir(path, year: Time.now.year)
      Dir["#{path}/*.csv"].each do |csv_path|
        parse_table(CSV.read(csv_path, headers: true), year:)
      end
    end

    def parse_table(table, year:)
      week_no = 1
      weeks = Season.find_by(year:).weeks.index_by(&:week)
      teams = Team.all.index_by(&:name)

      table.each do |row|
        next if row["competition"].include?("Preseason")

        kickoff = Time.parse("#{row["date"]} #{row["time"]}")
        week = weeks[week_no]

        if kickoff > week.starts_at + 1.week
          # there was a bye week. increase week_no
          week_no += 1
          week = weeks[week_no]
        end

        home = teams[row["home_team"]]
        away = teams[row["away_team"]]

        action =
          if week.matchups.where(home:, away:).exists?
            "already exists"
          else
            week.matchups.create!(
              kickoff:,
              home:,
              away:,
            )
            "created"
          end
        puts "Week #{week_no} matchup #{home.initials} @ #{away.initials} #{action}"

        week_no += 1
      end
    end
  end
end
