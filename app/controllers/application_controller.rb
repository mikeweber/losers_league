class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  around_action :set_time_zone

  before_action :capture_user_id

  if Rails.env.development?
    before_action :capture_test_time
  end

  private

  def set_time_zone
    Time.use_zone("Central Time (US & Canada)") { yield }
  end

  helper_method def current_user
    return nil if session[:current_user_id].nil?

    @current_user ||= User.find(session[:current_user_id])
  end

  helper_method def current_time
    @current_time ||=
      if session[:fake_time]
        Time.at(session[:fake_time])
      else
        Time.now
      end
  end

  def capture_user_id
    return unless params.key?(:secret_key)

    if params[:secret_key].blank?
      session[:current_user_id] = nil
    elsif (@current_user = User.find_by(secret_identifier: params[:secret_key]))
      session[:current_user_id] = @current_user.id
    end
  end

  def capture_test_time
    return unless params.key?(:fake_time)

    if params[:fake_time].blank?
      session[:fake_time] = nil
    else
      session[:fake_time] = (@current_time = Time.parse(params[:fake_time])).to_i
    end
  end
end
