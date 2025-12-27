class FunFact
  attr_reader :season

  def initialize(season:)
    @season = season
  end

  def copies
    highest_copy_count = 0

    # First, find out the highest copy count...
    duplicate_pick_counts.each do |_user_id, count|
      highest_copy_count = count if count > highest_copy_count
    end

    # ... then find which users have that count
    duplicate_pick_counts.filter_map { |user_name, count| [user_name, count] if count == highest_copy_count }
  end

  def most_original
    lowest_copy_count = nil

    # First, find out the highest copy count...
    duplicate_pick_counts.each do |_user_id, count|
      lowest_copy_count = count if lowest_copy_count.nil? || count < lowest_copy_count
    end

    # ... then find which users have that count
    duplicate_pick_counts.filter_map { |user_name, count| [user_name, count] if count == lowest_copy_count }
  end

  # The one person who picked the same winning team the most
  def super_fan
    return @super_fan if defined?(@super_fan)

    super_fan_count = 0
    favorite_teams.each do |_user, faves|
      super_fan_count = faves[:times] if faves[:times] > super_fan_count
    end

    super_fans = favorite_teams.filter_map do |user_name, faves|
      next unless faves[:times] == super_fan_count

      { name: user_name, team_initials: faves[:favorites], count: faves[:times] }
    end

    @super_fan = (super_fans.first if super_fans.size == 1)
  end

  # Each User's favorite winner
  #  {
  #    Boone: { favorites: [GB, PHI], times: 5 },
  #    ...
  #  }
  def favorite_teams
    return @favorite_teams if defined?(@favorite_teams)

    user_winner_counts = Hash.new { |h, k| h[k] = Hash.new { |h, k| h[k] = 0 } }
    weekly_picks.each do |week_id, picks|
      picks.each do |pick|
        pick.week = indexed_weeks[week_id]
        next if pick.matchup.nil?

        team_id = begin
          if pick.picked_home?
            pick.matchup.away_id
          elsif pick.picked_away?
            pick.matchup.home_id
          end
        end

        user_winner_counts[indexed_users[pick.user_id].name][indexed_teams[team_id].initials] += 1
      end
    end

    @favorite_teams = user_winner_counts.each.with_object({}) do |(user_name, winners), favorites|
      pick_count = 0
      winners.each do |team_initials, count|
        pick_count = count if count > pick_count
      end

      favorites[user_name] = {
        favorites: winners.filter_map { |team_initials, count| team_initials if count == pick_count },
        times: pick_count,
      }
    end
  end

  # Returns a hash of Users and how often they copied someone else
  # {
  #   Boone: 2, Shane: 5, Brandon: 3, ...
  # }
  def duplicate_pick_counts
    return @duplicates if defined?(@duplicates)

    @duplicates = Hash.new { |h, k| h[k] = 0 }

    weekly_picks_by_user.each do |week_number, picks|
      picks.each do |user_id, team_initials|
        next unless (other_picks = weekly_picks_by_team[week_number][team_initials])

        # Add the users who picked the same team that week, less 1 for the user's own pick
        @duplicates[indexed_users[user_id].name] += other_picks.size - 1
      end
    end

    @duplicates
  end

  # Returns a hash of Users, that counts the number of times another User copied them
  # {
  #   Mike: { Boone: 2, Shane: 5, Brandon: 3, ... },
  #   ...
  # }
  def duplicate_picks
    return @duplicate_picks if defined?(@duplicate_picks)

    @duplicate_picks = Hash.new { |h, k| h[k] = Hash.new { |h, k| h[k] = 0 } }

    weekly_picks_by_user.each do |week_number, picks|
      picks.each do |user_id, team_initials|
        next unless (other_user_ids = weekly_picks_by_team[week_number][team_initials])

        # For each users who picked the same team that week, add 1
        other_user_ids.each do |other_user_id|
          next if user_id == other_user_id

          @duplicate_picks[indexed_users[user_id].name][indexed_users[other_user_id].name] += 1
        end
      end
    end

    @duplicate_picks
  end

  # Returns the longest winning streak(s)
  def winning_streakers
    longest_streak = 0
    streaks.each do |user_name, streak|
      longest_streak = streak[:wins] if streak[:wins] > longest_streak
    end

    {
      count: longest_streak,
      names: streaks.filter_map { |user_name, streak| user_name if streak[:wins] == longest_streak },
    }
  end

  # Returns the longest losing streak(s)
  def losing_streakers
    longest_streak = 0
    streaks.each do |user_name, streak|
      longest_streak = streak[:losses] if streak[:losses] > longest_streak
    end

    {
      count: longest_streak,
      names: streaks.filter_map { |user_name, streak| user_name if streak[:losses] == longest_streak },
    }
  end

  def user_names
    @user_names ||= indexed_users.map { |_, user| user.name }.sort
  end

  def living_on_the_edge
    return @living_on_the_edge if defined?(@living_on_the_edge)

    lowest_median = nil
    median_records.each do |_user_name, record|
      lowest_median = record[:median] if lowest_median.nil? || record[:median] < lowest_median
    end

    {
      median: lowest_median,
      records: median_records.select { |_, record| record[:median] == lowest_median },
    }
  end

  def median_records
    return @median_records if defined?(@median_records)

    @median_records = Hash.new { |h, k| h[k] = { wins: 0, losses: 0 } }
    weekly_picks.each do |_week_id, picks|
      picks.each do |pick|
        median = median_scores[pick.user_id]
        next if pick.matchup.differential.nil? || pick.matchup.differential > median

        user = indexed_users[pick.user_id]
        key = pick.correct? ? :wins : :losses
        @median_records[user.name][:median] ||= median
        @median_records[user.name][key] += 1
      end
    end

    @median_records
  end

  private

  # Returns a hash of weeks, where each week includes picks, grouped by the team
  #  {
  #    1: { PHI: [<Mike ID>, <Boone ID>], MIN: [<Scott ID>], ... },
  #    ...
  #  }
  def weekly_picks_by_team
    return @weekly_picks_by_team if defined?(@weekly_picks_by_team)

    @weekly_picks_by_team = Hash.new { |h, k| h[k] = Hash.new { |i, j| i[j] = [] } }
    indexed_weeks.values.each do |week|
      weekly_picks_by_user[week.id].each do |user_id, team_initials|
        @weekly_picks_by_team[week.week][team_initials] << user_id
      end
    end

    @weekly_picks_by_team
  end

  def streaks
    return @streaks if defined?(@streaks)

    @streaks = indexed_users.to_h do |user_id, user|
      weekly_picks.each do |week_id, picks|
        picks.each do |pick|
          pick.week = indexed_weeks[week_id]
          pick.team = indexed_teams[pick.team_id]
        end
      end

      longest_winning_streak = 0
      active_winning_streak = 0
      longest_losing_streak = 0
      active_losing_streak = 0
      weekly_picks.sort_by { |week_id, picks| picks.first.week.week }.each do |_, picks|
        picks.each do |pick|
          next unless pick&.user_id == user_id

          if pick.correct?
            active_winning_streak += 1
            longest_winning_streak = active_winning_streak if active_winning_streak > longest_winning_streak
            active_losing_streak = 0
          else
            active_losing_streak += 1
            longest_losing_streak = active_losing_streak if active_losing_streak > longest_losing_streak
            active_winning_streak = 0
          end
        end
      end

      [user.name, { wins: longest_winning_streak, losses: longest_losing_streak }]
    end
  end

  def median_scores
    return @median_scores if defined?(@median_scores)

    differentials = Hash.new { |h, k| h[k] = [] }

    weekly_picks.flat_map do |week_id, picks|
      picks.map do |pick|
        pick.week = indexed_weeks[week_id]
        next if (diff = pick.matchup.differential).nil?

        differentials[pick.user_id] << diff
      end
    end

    @median_scores = differentials.each.with_object({}) do |(user_id, scores), h|
      h[user_id] = scores.sort[scores.size / 2]
    end
  end

  def indexed_users
    @users ||= User.all.index_by(&:id)
  end

  # {
  #   1: { <Boone ID>: PHI, <Scott ID>: PHI, ... },
  #   2: { <Boone ID>: MIN, <Scott ID>: ARI, ... },
  # }
  def weekly_picks_by_user
    @weekly_picks_by_user ||= weekly_picks.each.with_object(Hash.new { |h, k| h[k] = {} }) do |(week_id, picks), h|
      picks.each do |pick|
        h[indexed_weeks[week_id].week][pick.user_id] = indexed_teams[pick.team_id].initials
      end
    end
  end

  # {
  #   1: <week1_pick_array>,
  #   2: <week2_pick_array>,
  # }
  def weekly_picks
    @picks ||= Pick.joins(:week).where(week: { season_id: season.id }).group_by(&:week_id)
  end

  def indexed_weeks
    @weeks ||= season.weeks.preload(:matchups).index_by(&:id)
  end

  def indexed_teams
    @teams ||= Team.all.index_by(&:id)
  end
end
