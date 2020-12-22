class AddBooleanValueToTestModels < ActiveRecord::Migration[5.2]
  def change
    add_column :test_models, :some_boolean_value, :boolean
  end
end
