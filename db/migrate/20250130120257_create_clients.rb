class CreateClients < ActiveRecord::Migration[7.1]
  def change
    create_table :clients do |t|
      t.string :name
      t.decimal :total_spent
      t.integer :total_points

      t.timestamps
    end
  end
end
