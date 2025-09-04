class CreateMatchups < ActiveRecord::Migration[8.0]
  def change
    create_table :matchups do |t|
      t.references :week, null: false, foreign_key: true
      t.references :home, null: false, foreign_key: { to_table: :teams }
      t.references :away, null: false, foreign_key: { to_table: :teams }
      t.datetime :kickoff
      t.integer :home_score
      t.integer :away_score

      t.timestamps
    end
  end
end
