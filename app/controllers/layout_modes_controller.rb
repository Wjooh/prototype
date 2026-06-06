class LayoutModesController < ApplicationController
  def update
    session[:layout_mode] = %w[app mobile].include?(params[:mode]) ? params[:mode] : "mobile"
    head :no_content
  end
end
