class StandingsController < ApplicationController
  def index
    @year = params[:year] || Season.maximum(:year)
    @season = Season.find_by(year: @year)
    @users = User.all.sort_by { |user| [-user.correct_picks_for(season_id: @season.id).size, user.name] }
    @weeks = Week.joins(:season).where(season_id: @season.id).preload(picks: :team).order(:week)

    @statuses = @users.to_h { |user| [user.id, SeasonStatus.find_or_create_by(season: @season, user:)] }
    @weeks.each do |week|
      weekly_processor = WeeklyProcessor.new(week:, statuses: @statuses)
      weekly_processor.process! if weekly_processor.can_process?
    end
  end
end
