class CreateWeeks < ActiveRecord::Migration[8.0]
  def change
    create_table :weeks do |t|
      t.references :season, null: false, foreign_key: true
      t.integer :week, null: false
      t.datetime :starts_at, null: false

      t.timestamps
    end
  end
end
