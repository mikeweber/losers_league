# Gets the matchups and scores for a given week number
class ScheduleFetcher
  attr_reader :endpoint, :week_num

  def initialize(year:, week_num:, endpoint_class: ESPN::Endpoint)
    @week_num = week_num
    @endpoint = endpoint_class.new(year:, week: week_num)
  end

  def update_scores!
    endpoint.events.each do |event|
      next unless (matchup = matchups["#{event.away.initials} @ #{event.home.initials}"])

      if matchup.kickoff.nil? && event.kickoff.present?
        matchup.kickoff = event.kickoff
      end
      if !matchup.final? && event.final?
        matchup.home_score = event.home.score
        matchup.away_score = event.away.score
      end
      if matchup.home.logo_url.blank? && event.home.logo_url.present?
        matchup.home.update!(logo_url: event.home.logo_url)
      end
      if matchup.away.logo_url.blank? && event.away.logo_url.present?
        matchup.away.update!(logo_url: event.away.logo_url)
      end
      matchup.save!
    end
  end

  def matchups
    @matchups ||= week.matchups.each do |matchup|
      matchup.home = teams_by_id[matchup.home_id]
      matchup.away = teams_by_id[matchup.away_id]
    end.index_by { |m| "#{m.away.initials} @ #{m.home.initials}" }
  end

  def teams_by_id
    @teams_by_id ||= Team.all.index_by(&:id)
  end

  def week
    @week ||= schedule_builder.weeks.detect { _1.week == week_num }
  end

  def schedule_builder
    @schedule_builder ||= ScheduleBuilder.new(year: 2026)
  end
end
