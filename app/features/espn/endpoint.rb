require "net/http"

module ESPN
  class Endpoint
    API_URL = "https://site.web.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard"

    attr_reader :year, :week, :failure_message
    private attr_writer :year, :week, :failure_message
    private attr_accessor :fetched_response

    def initialize(year:, week:, fetched_response: nil)
      self.year = year
      self.week = week
      self.failure_message = nil
      self.fetched_response = fetched_response
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
      return fetched_response if fetched_response

      self.fetched_response = Net::HTTP.get_response(uri)

      if fetched_response.is_a?(Net::HTTPSuccess)
        self.failure_message = nil
        fetched_response
      else
        self.failure_message = fetched_response.message
        nil
      end
    end

    def uri
      URI(API_URL + "?year=#{year}&seasontype=2&week=#{week}")
    end
  end
end
