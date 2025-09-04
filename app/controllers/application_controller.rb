class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  around_action :set_time_zone

  private

  def set_time_zone
    Time.use_zone("Central Time (US & Canada)") { yield }
  end
end
