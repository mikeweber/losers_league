class PicksController < ApplicationController
  def create
    @now = Time.now

    @season = Season.find_by(year: params[:weekly_pick][:year] || Time.now.year)
    week_num = params[:weekly_pick][:week_num] || Week.current_week

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
    @weekly_pick = WeeklyPick.new(user: User.first, week: @week, losing_team: pick.team, now: @now)

    losing_team = Team.find(params[:weekly_pick][:loser_id])
    if @weekly_pick.pick_loser!(losing_team)
      redirect_to schedule_path(@week.season.year, @week.week), notice: "Pick submitted!"
    else
      render "schedule/index", status: :unprocessable_entity
    end
  end
end
