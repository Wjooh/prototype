module Day
  DATE = Date.new(2026, 11, 13)
  FIXTURE_PATH = Rails.root.join("db/fixtures/day.yml")

  def self.graph
    @graph ||= Graph.load
  end

  def self.reset!
    @graph = nil
  end
end
