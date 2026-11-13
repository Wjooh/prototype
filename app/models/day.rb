module Day
  DATE = Date.new(2026, 11, 13)
  FIXTURE_PATH = Rails.root.join("db/fixtures/day.yml")

  def self.graph
    mtime = File.mtime(FIXTURE_PATH)
    if @graph.nil? || @graph_mtime != mtime
      @graph = Graph.load
      @graph_mtime = mtime
    end
    @graph
  end

  def self.reset!
    @graph = nil
    @graph_mtime = nil
  end
end
