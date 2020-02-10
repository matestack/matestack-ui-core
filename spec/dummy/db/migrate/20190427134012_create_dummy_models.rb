class CreateDummyModels < ActiveRecord::Migration[5.2]
  def change
    create_table :dummy_models do |t|
      t.string :title
      t.text :description
      t.integer :status
      t.text :some_data
      t.text :more_data

      t.timestamps
    end
  end
end
