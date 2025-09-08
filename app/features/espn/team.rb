module ESPN
  class Team
    attr_reader :initials, :score, :logo_url

    class << self
      def parse_home(event_json)
        parse(parse_event(event_json, "home"))
      end

      def parse_away(event_json)
        parse(parse_event(event_json, "away"))
      end

      def parse_event(event_json, home_away)
        event_json["competitions"][0]["competitors"].detect do |comp|
          comp["homeAway"] == home_away
        end
      end

      def parse(competitor_json)
        new(
          initials: competitor_json.dig("team", "abbreviation"),
          score: competitor_json["score"],
          logo_url: competitor_json.dig("team", "logo"),
        )
      end
    end

    def initialize(initials:, score:, logo_url:)
      @initials = initials
      @score = score
      @logo_url = logo_url
    end
  end
end
