class MonitorOrdersController < ApplicationController
  layout "monitor"

  def index
    @date = Day::DATE
    @orders = Day.graph.orders
  end
end
