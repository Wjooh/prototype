class MonitorDeliveriesController < ApplicationController
  layout "monitor"

  def index
    @date = Day::DATE
    @deliveries = Day.graph.deliveries
  end
end

