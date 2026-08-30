# == Schema Information
#
# Table name: seasons
#
#  id         :bigint           not null, primary key
#  year       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Season < ApplicationRecord
  has_many :weeks
  has_many :season_statuses

  def current_week(now = Time.now)
    weeks.where(starts_at: ..(now + 2.days)).maximum(:week) || 1
  end
end
