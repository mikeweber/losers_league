module ESPN
  class Event
    STATUS_FINAL = "STATUS_FINAL".freeze
    STATUS_SCHEDULED = "STATUS_SCHEDULED".freeze
    TBD = "TBD".freeze

    attr_reader :week, :home, :away, :status, :kickoff

    class << self
      def parse_event(event_json)
        week = event_json.dig("week", "number")
        home = ESPN::Team.parse_home(event_json)
        away = ESPN::Team.parse_away(event_json)
        status = event_json.dig("status", "type", "name")
        kickoff = event_json.dig("status", "type", "shortDetail")

        new(week:, home:, away:, status:, kickoff:)
      end
    end

    def initialize(week:, home:, away:, status:, kickoff:)
      @week = week
      @home = home
      @away = away
      @status = status

      if scheduled?
        self.kickoff = kickoff
      end
    end

    def final?
      status == STATUS_FINAL
    end

    def scheduled?
      status == STATUS_SCHEDULED
    end

    private

    def kickoff=(time)
      return @kickoff = nil if time == TBD

      @kickoff = Time.parse(time)
    rescue
    end
  end
end
