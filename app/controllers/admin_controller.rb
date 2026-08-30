class AdminController < ApplicationController
  before_action :restrict_to_admin

  def overview
    @season = Season.find_by(year: params[:year] || current_time.year)
    redirect_to "/" if @season.nil?

    @weekly_counts = @season.weeks.sort_by(&:week).to_h do |week|
      [week.week, { matchups: week.matchups.count, picks: week.picks.count }]
    end
  end

  def new_season
  end

  def import_season
    builder = ScheduleBuilder.new(year: params.fetch(:year, current_time.year))

    builder.store_all_matchups!

    flash[:notice] = "#{builder.year} Season imported"
    redirect_to admin_overview_path
  end

  def import_week
    if params[:week].blank?
      redirect_to admin_overview_path
      return
    end
    builder = ScheduleBuilder.new(year: params.fetch(:year, current_time.year))

    builder.store_matchups!(week_num: params[:week])

    flash[:notice] = "#{builder.year} week #{params[:week]} imported"
    redirect_to admin_overview_path
  end

  private

  def restrict_to_admin
    redirect_to "/" unless current_user&.admin?
  end
end
