class ScheduleController < ApplicationController
  def index
    @season = Season.find_by(year: params[:year] || Time.now.year)
    week_num = params[:week] || Week.current_week

    @week = @season.weeks.find_by(week: week_num)
    teams = Team.all.index_by(&:id)
    @matchups = @week.matchups
    @matchups.each do |matchup|
      matchup.home = teams[matchup.home_id]
      matchup.away = teams[matchup.away_id]
    end
    @picks_allowed = current_user.present? && !@week.picks_locked?(current_time)
    pick = current_user.picks.find_or_initialize_by(week_id: @week.id) if current_user
    @weekly_pick = WeeklyPick.new(user: current_user, week: @week, losing_team: pick&.team, now: current_time)
  end
end
