class MonitorTimelineController < ApplicationController
  layout "monitor"

  PX_PER_HOUR = 200
  START_HOUR = 6
  END_HOUR = 20

  def index
    @date = Day::DATE
    @graph = Day.graph
    @supplier_orders = @graph.supplier_orders
    @deliveries = @graph.deliveries
    @px_per_hour = PX_PER_HOUR
    @start_hour = START_HOUR
    @end_hour = END_HOUR
    @timeline_width = (@end_hour - @start_hour) * @px_per_hour
    @show_cook = params[:cook] != "0"
    @show_delivery = params[:delivery] != "0"
  end
end
