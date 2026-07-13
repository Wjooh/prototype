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

  def show
    @party_types = PARTY_TYPES
  end
end
