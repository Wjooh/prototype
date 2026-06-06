class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :layout_mode

  private

  def layout_mode
    session[:layout_mode].presence_in(%w[app mobile]) || "mobile"
  end
end
