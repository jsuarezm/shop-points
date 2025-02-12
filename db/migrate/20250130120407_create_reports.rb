class CreateReports < ActiveRecord::Migration[7.1]
  def change
    create_table :reports do |t|
      t.string :status
      t.string :file_path

      t.timestamps
    end
  end
end
