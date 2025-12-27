class StandingsController < ApplicationController
  def index
    @year = params[:year] || current_time.year
    @season = Season.find_by(year: @year)
    @users = User.all.sort_by { |user| [-user.correct_picks_for(year: @year).size, user.name] }
    @weeks = Week.joins(:season).where(season_id: @season.id).preload(picks: :team).order(:week)

    @statuses = @users.to_h { |user| [user.id, SeasonStatus.find_or_create_by(season: @season, user:)] }
    @weeks.each do |week|
      weekly_processor = WeeklyProcessor.new(week:, statuses: @statuses)
      weekly_processor.process! if weekly_processor.can_process?
      @statuses.each do |user_id, status|
        weekly_processor.rebuy!(user_id) if status.can_rebuy? && user_id != 1
      end
    end
  end
end
