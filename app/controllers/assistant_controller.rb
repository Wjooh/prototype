class AssistantController < ApplicationController
  PARTY_TYPES = [
    {
      key: "adults",
      label: "Adults",
      description: "Birthday, dinner party, or celebration with friends",
      icon: "sparkles"
    },
    {
      key: "kids",
      label: "Kids",
      description: "Birthday bash or playdate for the little ones",
      icon: "gift"
    },
    {
      key: "corporate",
      label: "Corporate",
      description: "Office party, team event, or client gathering",
      icon: "building-office-2"
    }
  ].freeze

  VALID_PARTY_TYPES = PARTY_TYPES.map { |type| type[:key] }.freeze

  def show
    @step = [params.fetch(:step, 1).to_i, 1].max
    @party_types = PARTY_TYPES
    @party_type = params[:party_type].presence

    if @step >= 2
      unless VALID_PARTY_TYPES.include?(@party_type)
        redirect_to assistant_path and return
      end

      @step = 2
    else
      @step = 1
    end
  end
end
