class CreateDummyChildModels < ActiveRecord::Migration[5.2]
  def change
    create_table :dummy_child_models do |t|
      t.string :title
      t.text :description
      t.integer :status
      t.text :some_data
      t.text :more_data

      t.timestamps
    end
    add_reference :dummy_child_models, :dummy_model, foreign_key: true
  end
end
