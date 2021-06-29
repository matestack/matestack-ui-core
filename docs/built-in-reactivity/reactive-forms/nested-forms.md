# Nested Forms

Matestack provides functionality for reactive nested forms.

This works in conjunction with rails' `accepts_nested_attributes_for`. From the rails documentation on [nested attributes](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html):

> Nested attributes allow you to save attributes on associated records through the parent. By default nested attribute updating is turned off and you can enable it using the accepts_nested_attributes_for class method. When you enable nested attributes an attribute writer is defined on the model.

There is a little bit of setup required to enable this. There's a need for `accepts_nested_attributes_for`,  `index_errors` on a models' `has_many` associations and an ActiveRecord patch.


Consider the following model setup, which is the same model found in the dummy app in the spec directory (active in this dummy app):

```ruby
class DummyModel < ApplicationRecord
  validates :title, presence: true, uniqueness: true
  has_many :dummy_child_models, index_errors: true
  accepts_nested_attributes_for :dummy_child_models, allow_destroy: true
end

class DummyChildModel < ApplicationRecord
  validates :title, presence: true, uniqueness: true
end
```

## Index Errors

Note the `has_many :dummy_child_models, index_errors: true` declaration in the `Dummy Model` declaration above.

Normally with rails, when rendering forms using Active Record models, errors are available on individual model instances. When using `accepts_nested_attributes_for`, error messages sent as JSON are not as useful because it is not possible to figure out which associated model object the error relates to.

From rails 5, we can add an index to errors on nested models. We can add the option `index_errors: true` to has_many association to enable this behaviour on individual association.


## ActiveRecord Patch

Matestack nested forms support requires an ActiveRecord patch. This is because `index_errors` does not consider indexes of the correct existing sub records.

See rails [issue #24390](https://github.com/rails/rails/issues/24390)

Add this monkey patch to your rails app

```ruby
module ActiveRecord
  module AutosaveAssociation
    def validate_collection_association(reflection)
      if association = association_instance_get(reflection.name)
        if records = associated_records_to_validate_or_save(association, new_record?, reflection.options[:autosave])
          all_records = association.target.find_all
          records.each do |record|
            index = all_records.find_index(record)
            association_valid?(reflection, record, index)
          end
        end
      end
    end
  end
end
```

## Example

```ruby
class ExamplePage < Matestack::Ui::Page

  def prepare
    @dummy_model = DummyModel.new
    @dummy_model.dummy_child_models.build(title: "init-value")
    @dummy_model.dummy_child_models.build
  end

  def response
    matestack_form form_config do
      form_input key: :title, type: :text, label: "dummy_model_title_input", id: "dummy_model_title_input"

      @dummy_model.dummy_child_models.each do |dummy_child_model|
        dummy_child_model_form dummy_child_model
      end

      form_fields_for_add_item key: :dummy_child_models_attributes, prototype: method(:dummy_child_model_form) do
        # type: :button is important! otherwise remove on first item is triggered on enter
        button "add", type: :button
      end

      form_fields_for_remove_item do
        # id is just required in this spec, but type: :button is important! otherwise remove on first item is triggered on enter
        button "remove", ":id": "'remove'+nestedFormRuntimeId", type: :button
      end

      button "Submit me!"

      toggle show_on: "success", hide_after: 1000 do
        plain "success!"
      end
      toggle show_on: "failure", hide_after: 1000 do
        plain "failure!"
      end
    end
  end

  def dummy_child_model_form dummy_child_model = DummyChildModel.new
    form_fields_for dummy_child_model, key: :dummy_child_models_attributes do
      form_input key: :title, type: :text, label: "dummy-child-model-title-input"
      form_fields_for_remove_item do
        # id is just required in this spec, but type: :button is important! otherwise remove on first item is triggered on enter
        button "remove", ":id": "'remove'+nestedFormRuntimeId", type: :button
      end
    end
  end
end
```

### Dynamically Adding Nested Items

As in the example above, you can dynamically add nested items. As the comment in the code suggests `type: :button` is important, otherwise remove on first item is triggered on enter.

```ruby
form_fields_for_add_item key: :dummy_child_models_attributes, prototype: method(:dummy_child_model_form) do
# type: :button is important! otherwise remove on first item is triggered on enter
button "add", type: :button
end
```

### Dynamically Removing Nested Items

As in the example above, as well as dynamically adding items, you can dynamically remove nested items. Again, important: `type: :button` is important, otherwise remove on first item is triggered on enter.

```ruby
form_fields_for_remove_item do
  # id is just required in this spec, but type: :button is important! otherwise remove on first item is triggered on enter
  button "remove", ":id": "'remove'+nestedFormRuntimeId", type: :button
end
```
