class CreateSeasonStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :season_statuses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :season, null: false, foreign_key: true
      t.string :status, null: false, default: "playing"
      t.integer :processed_week, null: false, default: 0
      t.integer :wins, null: false, default: 0
      t.integer :losses, null: false, default: 0
      t.boolean :took_rebuy, null: false, default: false

      t.timestamps
    end

    add_index :season_statuses, [:user_id, :season_id], unique: true
  end
end
