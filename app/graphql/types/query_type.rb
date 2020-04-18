# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :zone, ::Types::Zones::Zone, null: false, description: "Zone data" do
      argument :slug, String, required: true
    end

    field :zones_list, [::Types::Zones::Zone], null: false, description: "List of all zones" do
      argument :search_query, String, required: false
    end

    field :home, ::Types::Home::HomeData, null: false

    def zone(slug:)
      ::Zone.find_by(slug: slug)
    end

    def zones_list(search_query:)
      ::Zone.where("search_name LIKE ?", "%#{search_query.parameterize}%").distinct(:slug).order(:name).limit(20)
    end

    def home
      confirmed = ::TimeSeriesPoint.where(target_code: "in").map(&:announced).sum
      recovered = ::TimeSeriesPoint.where(target_code: "in").map(&:recovered).sum
      deceased = ::TimeSeriesPoint.where(target_code: "in").map(&:deceased).sum
      {
        cases: [
          { label: "Active", name: "active", value: confirmed - recovered - deceased },
          # { label: "Recovered", name: "recovered", value: recovered },
          # { label: "Deceased", name: "deceased", value: deceased }
        ]
      }
    end
  end
end
