module FixtureLoadable
  extend ActiveSupport::Concern

  class_methods do
    def all
      @all ||= load_records
    end

    def reset!
      @all = nil
    end

    def fixture_path
      raise NotImplementedError
    end

    def load_records
      raise NotImplementedError
    end
  end
end
