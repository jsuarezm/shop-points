class CreatePurchases < ActiveRecord::Migration[7.1]
  def change
    create_table :purchases do |t|
      t.references :client, null: false, foreign_key: true
      t.decimal :amount

      t.timestamps
    end
  end
end
