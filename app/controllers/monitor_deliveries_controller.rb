class MonitorDeliveriesController < ApplicationController
  layout "monitor"

  def index
    @date = Day::DATE
    @graph = Day.graph
    @orders = @graph.orders
    @deliveries = @graph.deliveries
  end
end
