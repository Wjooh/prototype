class MonitorTimelineController < ApplicationController
  layout "monitor"

  PX_PER_HOUR = 200
  START_HOUR = 6
  END_HOUR = 20

  def index
    @date = Day::DATE
    @graph = Day.graph
    @px_per_hour = PX_PER_HOUR
    @start_hour = START_HOUR
    @end_hour = END_HOUR
    @timeline_width = (@end_hour - @start_hour) * @px_per_hour
    @focus_suppliers = @graph.suppliers
    allowed = %w[prep delivery] + @focus_suppliers.map(&:id) + @graph.orders.map(&:id)
    @focus = allowed.include?(params[:focus]) ? params[:focus] : nil
    @show_continuity = params[:continuity] == "1"
    @layout = Day::TimelineLayout.new(
      @graph,
      px_per_hour: @px_per_hour,
      start_hour: @start_hour,
      end_hour: @end_hour
    )
  end
end
