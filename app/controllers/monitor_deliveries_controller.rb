class MonitorDeliveriesController < ApplicationController
  layout "monitor"

  def index
    @date = Day::DATE
    @graph = Day.graph
    @now_hm = @graph.now_hm
    @deliveries = @graph.deliveries
  end
end


