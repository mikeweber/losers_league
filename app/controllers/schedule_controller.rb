class ScheduleController < ApplicationController
  def index
    @now = Time.now

    @season = Season.find_by(year: params[:year] || Time.now.year)
    week_num = params[:week] || Week.current_week

    @week = @season.weeks.find_by(week: week_num)
    teams = Team.all.index_by(&:id)
    @matchups = @week.matchups
    @matchups.each do |matchup|
      matchup.home = teams[matchup.home_id]
      matchup.away = teams[matchup.away_id]
    end
    @picks_allowed = true
    user = User.first
    pick = user.picks.find_or_initialize_by(week_id: @week.id)
    @weekly_pick = WeeklyPick.new(user:, week: @week, losing_team: pick&.team, now: @now)
  end
end
