class ScheduleController < ApplicationController
  def index
    year = params[:year] || Season.maximum(:year)
    @season = Season.find_by(year: year)
    week_num = params.fetch(:week, @season.current_week)

    @week = @season.weeks.find_by(week: week_num)
    teams = Team.all.index_by(&:id)
    @matchups = @week.matchups.each do |matchup|
      matchup.home = teams[matchup.home_id]
      matchup.away = teams[matchup.away_id]
    end.sort
    if @week.picks_locked?(current_time) && @matchups.any? { |matchup| matchup.missing_score?(current_time) }
      fetch_scores(season: @season, week: @week)
    end
    @picks_allowed = current_user.present? && !@week.picks_locked?(current_time)
    pick = current_user.picks.detect { _1.week_id == @week.id } || current_user.picks.new(week_id: @week.id) if current_user
    @weekly_pick = WeeklyPick.new(user: current_user, week: @week, losing_team_id: pick&.team_id, now: current_time)
  end

  private

  def fetch_scores(season:, week:)
    Rails.logger.info("Fetching matchup results...")
    ScheduleFetcher.new(year: season.year, week_num: week.week).update_scores!
  end
end
