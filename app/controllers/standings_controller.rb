class StandingsController < ApplicationController
  def index
    @year = params[:year] || current_time.year
    @users = User.all.sort_by { |user| [-user.correct_picks_for(year: @year).size, user.name] }
    @weeks = Week.joins(:season).where(seasons: { year: @year }).preload(picks: :team)
  end
end
