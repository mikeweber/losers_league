# == Schema Information
#
# Table name: picks
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  team_id    :bigint           not null
#  user_id    :bigint           not null
#  week_id    :bigint           not null
#
# Indexes
#
#  index_picks_on_team_id  (team_id)
#  index_picks_on_user_id  (user_id)
#  index_picks_on_week_id  (week_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (week_id => weeks.id)
#
require 'rails_helper'

RSpec.describe Pick, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
