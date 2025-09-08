class AddLogoUrlToTeams < ActiveRecord::Migration[8.0]
  def change
    add_column :teams, :logo_url, :string
  end
end
