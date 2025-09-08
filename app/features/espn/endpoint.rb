require "net/http"

module ESPN
  class Endpoint
    API_URL = "https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard"

    attr_reader :week, :failure_message
    private attr_writer :week, :failure_message

    def initialize(week:)
      self.week = week
      self.failure_message = nil
    end

    def events
      json_response["events"].flat_map do |event_json|
        ESPN::Event.parse_event(event_json)
      end
    end

    def json_response
      return if response.nil?

      @json_response ||= JSON.parse(response_body)
    end

    def response_body
      response&.body
    end

    def response
      return @response if defined?(@response)

      @response = fetch
    end

    def fetch
      fetched_response = Net::HTTP.get_response(uri)

      if fetched_response.is_a?(Net::HTTPSuccess)
        self.failure_message = nil
        fetched_response
      else
        self.failure_message = fetched_response.message
        nil
      end
    end

    def uri
      URI(API_URL + "?seasontype=2&week=#{week}")
    end
  end
end
