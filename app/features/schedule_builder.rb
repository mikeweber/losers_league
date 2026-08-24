# Create the season and weeks records. Can also import the schedule from the ESPN endpoint and use
# that to create the matchups.
class ScheduleBuilder
  SEASON_LENGTH = 18
  SEASON_START = Time.new(2026, 9, 9)

  attr_reader :year, :endpoint_class

  def initialize(year:, endpoint_class: ESPN::Endpoint)
    @year = year
    @endpoint_class = endpoint_class
  end

  def weeks
    @weeks ||= SEASON_LENGTH.times.map do |i|
      week_for(week_num: i + 1)
    end
  end

  def store_all_matchups!
    weeks.each do |week|
      store_matchups!(week_num: week.week)
    end
  end

  def store_matchups!(week_num:)
    external_schedule_for(week_num:).events.map do |event|
      away = teams_by_initials[event.away.initials]
      home = teams_by_initials[event.home.initials]
      matchup = week_for(week_num:).matchups.find_or_create_by(
        home_id: home.id,
        away_id: away.id,
      )
      matchup.update!(kickoff: event.kickoff)
      matchup
    end
  end

  def week_for(week_num:)
    season.weeks.detect { _1.week == week_num } || create_week!(week_num:)
  end

  def season
    @season ||= Season.find_or_create_by(year:)
  end

  private

  def teams_by_initials
    @teams_by_initials ||= Team.all.index_by(&:initials)
  end

  def create_week!(week_num:)
    SEASON_LENGTH.times do |i|
      week = i + 1
      starts_at = SEASON_START + i.weeks
      season.weeks.create!(week:, starts_at:)
    end
  end

  def external_schedule_for(week_num:)
    @external_schedules ||= {}
    @external_schedules[week_num] ||= endpoint_class.new(year:, week: week_num)
  end
end
