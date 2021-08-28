require_relative "../../../support/utils"
require_relative "../../../support/test_controller"
require_relative "support/form_test_controller"
require_relative "support/model_form_test_controller"
include Utils

describe "nested forms supporting nested attributes API from ActiveRecord models", type: :feature, js: true do

  ## Assuming following model setup (active in this dummy app):

  # class DummyModel < ApplicationRecord
  #   validates :title, presence: true, uniqueness: true
  #
  #   has_many :dummy_child_models, index_errors: true #https://bigbinary.com/blog/errors-can-be-indexed-with-nested-attrbutes-in-rails-5
  #   accepts_nested_attributes_for :dummy_child_models, allow_destroy: true
  # end
  #
  # class DummyChildModel < ApplicationRecord
  #   validates :title, presence: true, uniqueness: true
  # end

  ## Requires following ActiveRecord patch (via initializer in this dummy app):

  # Support propper mapping of errors on existing nested models in nested forms
  # https://github.com/rails/rails/issues/24390#issuecomment-703708842

  # module ActiveRecord
  #   module AutosaveAssociation
  #     def validate_collection_association(reflection)
  #       if association = association_instance_get(reflection.name)
  #         if records = associated_records_to_validate_or_save(association, new_record?, reflection.options[:autosave])
  #           all_records = association.target.find_all
  #           records.each do |record|
  #             index = all_records.find_index(record)
  #             association_valid?(reflection, record, index)
  #           end
  #         end
  #       end
  #     end
  #   end
  # end

  # Requires proper strong params setup:

  class NestedFormTestController < TestController
    include Matestack::Ui::Core::Helper

    def form_submit
      dummy_model = DummyModel.create(dummy_model_params)
      if dummy_model.errors.any?
        render json: {
          message: "server says: something went wrong!",
          errors: dummy_model.errors
        }, status: :unprocessable_entity
      else
        render json: {
          message: "server says: form submitted successfully!"
        }, status: :ok
      end
    end

    def form_submit_update
      dummy_model = DummyModel.find(params[:id])
      dummy_model.update(dummy_model_params)
      if dummy_model.errors.any?
        render json: {
          message: "server says: something went wrong!",
          errors: dummy_model.errors
        }, status: :unprocessable_entity
      else
        render json: {
          message: "server says: form submitted successfully!"
        }, status: :ok
      end
    end

    protected

    def dummy_model_params
      params.require(:dummy_model).permit(
        :title,
        :description,
        :file,
        files: [],
        dummy_child_models_attributes: [:id, :_destroy, :title, :description, :file, files: []]
      )
    end
  end


  before :all do
    Rails.application.routes.append do
      scope "nested_forms_spec" do
        post '/submit', to: 'nested_form_test#form_submit', as: 'nested_forms_spec_submit'
        put '/submit_update/:id', to: 'nested_form_test#form_submit_update', as: 'nested_forms_spec_submit_update'
      end
    end
    Rails.application.reload_routes!
  end

  before :each do
    ActiveStorage::Attachment.all.each { |attachment| attachment.purge }
    DummyChildModel.destroy_all
    DummyModel.destroy_all
    allow_any_instance_of(NestedFormTestController).to receive(:expect_params)
  end

  describe "working in context of a NEW parent model with multiple NEW child models" do

    before do
      class ExamplePage < Matestack::Ui::Page

        def prepare
          @dummy_model = DummyModel.new
          @dummy_model.dummy_child_models.build
          @dummy_model.dummy_child_models.build
        end

        def response
          matestack_form form_config do
            form_input key: :title, type: :text, label: "dummy_model_title_input", id: "dummy_model_title_input"

            @dummy_model.dummy_child_models.each do |dummy_child_model|
              form_fields_for dummy_child_model, key: :dummy_child_models_attributes do
                form_input key: :title, type: :text, label: "dummy-child-model-title-input"
              end
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

        def form_config
          {
            for: @dummy_model,
            method: :post,
            path: nested_forms_spec_submit_path,
            success: { emit: "success" },
            failure: { emit: "failure" }
          }
        end
      end
    end

    it "submits properly and enables creation of child elements via Rails nested attrbutes approach" do
      visit "/example"

      expect_any_instance_of(NestedFormTestController).to receive(:expect_params)
        .with(
          hash_including(dummy_model: {
            title: 'dummy-model-title-value',
            dummy_child_models_attributes: [
              { id: nil, _destroy: false, title: "dummy-child-model-title-0-value" },
              { id: nil, _destroy: false, title: "dummy-child-model-title-1-value" }
            ]
          }
        )
      )
      expect(page).to have_content('dummy_model_title_input', count: 1)
      expect(page).to have_content('dummy-child-model-title-input', count: 2)

      fill_in "dummy_model_title_input", with: "dummy-model-title-value"
      fill_in "title_dummy_child_models_attributes_child_0", with: "dummy-child-model-title-0-value"
      fill_in "title_dummy_child_models_attributes_child_1", with: "dummy-child-model-title-1-value"

      expect {
        click_button "Submit me!"
        expect(page).to have_content("success!") # required to work properly!
        # expect proper form reset
        expect(page.find("#dummy_model_title_input").value).to eq("")
        expect(page.find("#title_dummy_child_models_attributes_child_0").value).to eq("")
        expect(page.find("#title_dummy_child_models_attributes_child_1").value).to eq("")
      }
      .to change { DummyModel.count }.by(1)
      .and change { DummyChildModel.count }.by(2)
    end

    it "submits properly and maps errors back on the right inputs" do
      visit "/example"

      expect_any_instance_of(NestedFormTestController).to receive(:expect_params)
        .with(
          hash_including(dummy_model: {
            title: '',
            dummy_child_models_attributes: [
              { id: nil, _destroy: false, title: "" },
              { id: nil, _destroy: false, title: "dummy-child-model-title-1-value" }
            ]
          }
        )
      )

      fill_in "dummy_model_title_input", with: "" # required input, trigger server validation
      fill_in "title_dummy_child_models_attributes_child_0", with: "" # required input, trigger server validation
      fill_in "title_dummy_child_models_attributes_child_1", with: "dummy-child-model-title-1-value"

      expect {
        click_button "Submit me!"
        expect(page).to have_content("failure!") # required to work properly!
        expect(page).to have_selector("#dummy_model_title_input + .errors > .error", text: "can't be blank")
        expect(page).to have_selector("#title_dummy_child_models_attributes_child_0 + .errors > .error", text: "can't be blank")
        expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_1 + .errors > .error", text: "can't be blank")
      }
      .to change { DummyModel.count }.by(0)
      .and change { DummyChildModel.count }.by(0)
    end

    it "submits properly and maps errors back on the right inputs and resets errors properly when missing input was provided" do
      visit "/example"

      fill_in "dummy_model_title_input", with: "" # required input, trigger server validation
      fill_in "title_dummy_child_models_attributes_child_0", with: "" # required input, trigger server validation
      fill_in "title_dummy_child_models_attributes_child_1", with: "dummy-child-model-title-1-value"

      click_button "Submit me!"
      expect(page).to have_content("failure!") # required to work properly!

      # fill in missing values
      fill_in "dummy_model_title_input", with: "dummy-model-title-value"
      fill_in "title_dummy_child_models_attributes_child_0", with: "dummy-child-model-title-0-value"
      fill_in "title_dummy_child_models_attributes_child_1", with: "dummy-child-model-title-1-value"

      #expect erros to disappear
      expect(page).not_to have_selector("#dummy_model_title_input + .errors > .error", text: "can't be blank")
      expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_0 + .errors > .error", text: "can't be blank")

      expect_any_instance_of(NestedFormTestController).to receive(:expect_params)
        .with(
          hash_including(dummy_model: {
            title: 'dummy-model-title-value',
            dummy_child_models_attributes: [
              { id: nil, _destroy: false, title: "dummy-child-model-title-0-value" },
              { id: nil, _destroy: false, title: "dummy-child-model-title-1-value" }
            ]
          }
        )
      )

      # expect proper form submission
      expect {
        click_button "Submit me!"
        expect(page).to have_content("success!") # required to work properly!
        # expect proper form reset
        expect(page.find("#dummy_model_title_input").value).to eq("")
        expect(page.find("#title_dummy_child_models_attributes_child_0").value).to eq("")
        expect(page.find("#title_dummy_child_models_attributes_child_1").value).to eq("")
      }
      .to change { DummyModel.count }.by(1)
      .and change { DummyChildModel.count }.by(2)
    end

    it "is properly initialized through AR model instance attributes" do

      class ExamplePage < Matestack::Ui::Page

        def prepare
          @dummy_model = DummyModel.new
          @dummy_model.dummy_child_models.build(title: "init-value")
          @dummy_model.dummy_child_models.build
        end

      end
      visit "/example"

      expect(page.find("#dummy_model_title_input").value).to eq("")
      expect(page.find("#title_dummy_child_models_attributes_child_0").value).to eq("init-value")
      expect(page.find("#title_dummy_child_models_attributes_child_1").value).to eq("")

      fill_in "dummy_model_title_input", with: "dummy-model-title-value"
      # fill_in "title_dummy_child_models_attributes_child_0", with: "dummy-child-model-title-0-value" # via init value
      fill_in "title_dummy_child_models_attributes_child_1", with: "dummy-child-model-title-1-value"

      expect_any_instance_of(NestedFormTestController).to receive(:expect_params)
        .with(
          hash_including(dummy_model: {
            title: "dummy-model-title-value",
            dummy_child_models_attributes: [
              { id: nil, _destroy: false, title: "init-value" },
              { id: nil, _destroy: false, title: "dummy-child-model-title-1-value" }
            ]
          }
        )
      )

      expect {
        click_button "Submit me!"
        expect(page).to have_content("success!") # required to work properly!
        expect(page.find("#dummy_model_title_input").value).to eq("")
        expect(page.find("#title_dummy_child_models_attributes_child_0").value).to eq("init-value")
        expect(page.find("#title_dummy_child_models_attributes_child_1").value).to eq("")
      }
      .to change { DummyModel.count }.by(1)
      .and change { DummyChildModel.count }.by(2)
    end

    describe "supports dynamic removal of nested forms of NEW instances" do

      before do
        class ExamplePage < Matestack::Ui::Page
          def response
            matestack_form form_config do
              form_input key: :title, type: :text, label: "dummy_model_title_input", id: "dummy_model_title_input"

              @dummy_model.dummy_child_models.each do |dummy_child_model|
                form_fields_for dummy_child_model, key: :dummy_child_models_attributes do
                  form_input key: :title, type: :text, label: "dummy-child-model-title-input"
                  form_fields_for_remove_item do
                    button "remove", ":id": "'remove'+nestedFormRuntimeId", type: :button # id is just required in this spec, but type: :button is important! otherwise remove on first item is triggered on enter
                  end
                end
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
        end
      end

      it "submits properly with _destroy: true on each element which was removed" do
        visit "/example"

        expect(page).to have_selector('#dummy_model_title_input')
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_0')
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_1')

        expect(page).to have_selector("a.matestack-ui-core-form-fields-for-remove-item", count: 2)

        fill_in "dummy_model_title_input", with: "dummy-model-title-value"
        fill_in "title_dummy_child_models_attributes_child_0", with: "dummy-child-model-title-0-value"
        fill_in "title_dummy_child_models_attributes_child_1", with: "dummy-child-model-title-1-value"

        click_on("remove_dummy_child_models_attributes_child_0")

        expect(page).to have_selector('#dummy_model_title_input')
        expect(page).not_to have_selector('#title_dummy_child_models_attributes_child_0')
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_1')

        expect(page).to have_selector("a.matestack-ui-core-form-fields-for-remove-item", count: 1)

        expect_any_instance_of(NestedFormTestController).to receive(:expect_params)
          .with(
            hash_including(dummy_model: {
              title: 'dummy-model-title-value',
              dummy_child_models_attributes: [
                { id: nil, _destroy: true, title: "dummy-child-model-title-0-value" },
                { id: nil, _destroy: false, title: "dummy-child-model-title-1-value" }
              ]
            }
          )
        )

        expect {
          click_button "Submit me!"
          expect(page).to have_content("success!") # required to work properly!
          # expect proper form reset (removed item stays removed)
          expect(page).to have_selector('#dummy_model_title_input')
          expect(page).not_to have_selector('#title_dummy_child_models_attributes_child_0')
          expect(page).to have_selector('#title_dummy_child_models_attributes_child_1')
          expect(page.find("#dummy_model_title_input").value).to eq("")
          expect(page.find("#title_dummy_child_models_attributes_child_1").value).to eq("")
        }
        .to change { DummyModel.count }.by(1)
        .and change { DummyChildModel.count }.by(1)
      end

      it "maps errors properly back" do
        visit "/example"

        fill_in "dummy_model_title_input", with: "dummy-model-title-value"
        fill_in "title_dummy_child_models_attributes_child_0", with: "dummy-child-model-title-0-value"
        fill_in "title_dummy_child_models_attributes_child_1", with: "" # trigger server validation

        click_on("remove_dummy_child_models_attributes_child_0")

        expect {
          click_button "Submit me!"
          expect(page).to have_content("failure!") # required to work properly!
          # expect proper form reset (removed item stays removed)
          expect(page).not_to have_selector("#dummy_model_title_input + .errors > .error", text: "can't be blank")
          expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_0 + .errors > .error", text: "can't be blank")
          expect(page).to have_selector("#title_dummy_child_models_attributes_child_1 + .errors > .error", text: "can't be blank")
        }
        .to change { DummyModel.count }.by(0)
        .and change { DummyChildModel.count }.by(0)
      end
    end

    describe "supports dynamic addition of nested forms for NEW instances" do

      before do
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
                button "add", type: :button # type: :button is important! otherwise remove on first item is triggered on enter
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
                button "remove", ":id": "'remove'+nestedFormRuntimeId", type: :button # id is just required in this spec, but type: :button is important! otherwise remove on first item is triggered on enter
              end
            end
          end
        end
      end

      it "dynamically adds unlimited new nested forms and submits/resets all data properly" do
        visit "/example"
        # sleep
        expect(page).to have_selector('#dummy_model_title_input')
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_0')
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_1')
        expect(page).not_to have_selector('#title_dummy_child_models_attributes_child_2')
        expect(page).not_to have_selector('#title_dummy_child_models_attributes_child_3')

        click_on "add"
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_2')
        click_on "add"
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_3')

        fill_in "dummy_model_title_input", with: "dummy-model-title-value"

        # fill_in "title_dummy_child_models_attributes_child_1", with: "dummy-child-model-title-1-value" # already filled in via init value
        fill_in "title_dummy_child_models_attributes_child_1", with: "dummy-child-model-title-1-value"
        fill_in "title_dummy_child_models_attributes_child_2", with: "dummy-child-model-title-2-value"
        fill_in "title_dummy_child_models_attributes_child_3", with: "dummy-child-model-title-3-value"

        expect_any_instance_of(NestedFormTestController).to receive(:expect_params)
          .with(
            hash_including(dummy_model: {
              title: 'dummy-model-title-value',
              dummy_child_models_attributes: [
                { id: nil, _destroy: false, title: "init-value" },
                { id: nil, _destroy: false, title: "dummy-child-model-title-1-value" },
                { id: nil, _destroy: false, title: "dummy-child-model-title-2-value" },
                { id: nil, _destroy: false, title: "dummy-child-model-title-3-value" }
              ]
            }
          )
        )

        expect {
          click_button "Submit me!"
          expect(page).to have_content("success!") # required to work properly!
          # expect proper form reset (added items are kept, but value is resetted)
          expect(page).to have_selector('#dummy_model_title_input')
          expect(page).to have_selector('#title_dummy_child_models_attributes_child_0')
          expect(page).to have_selector('#title_dummy_child_models_attributes_child_1')
          expect(page).to have_selector('#title_dummy_child_models_attributes_child_2')
          expect(page).to have_selector('#title_dummy_child_models_attributes_child_3')
          expect(page.find("#dummy_model_title_input").value).to eq("")
          expect(page.find("#title_dummy_child_models_attributes_child_0").value).to eq("init-value")
          expect(page.find("#title_dummy_child_models_attributes_child_1").value).to eq("")
          expect(page.find("#title_dummy_child_models_attributes_child_2").value).to eq("")
          expect(page.find("#title_dummy_child_models_attributes_child_3").value).to eq("")
        }
        .to change { DummyModel.count }.by(1)
        .and change { DummyChildModel.count }.by(4)
      end

      it "dynamically adds unlimited new nested forms and submits/resets all data properly" do
        visit "/example"
        # sleep
        expect(page).to have_selector('#dummy_model_title_input')
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_0')
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_1')
        expect(page).not_to have_selector('#title_dummy_child_models_attributes_child_2')
        expect(page).not_to have_selector('#title_dummy_child_models_attributes_child_3')

        click_on "add"
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_2')
        click_on "add"
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_3')

        fill_in "dummy_model_title_input", with: "dummy-model-title-value"

        # fill_in "title_dummy_child_models_attributes_child_1", with: "dummy-child-model-title-1-value" # already filled in via init value
        fill_in "title_dummy_child_models_attributes_child_1", with: "dummy-child-model-title-1-value"
        fill_in "title_dummy_child_models_attributes_child_2", with: "dummy-child-model-title-2-value"
        fill_in "title_dummy_child_models_attributes_child_3", with: "dummy-child-model-title-3-value"

        expect_any_instance_of(NestedFormTestController).to receive(:expect_params)
          .with(
            hash_including(dummy_model: {
              title: 'dummy-model-title-value',
              dummy_child_models_attributes: [
                { id: nil, _destroy: false, title: "init-value" },
                { id: nil, _destroy: false, title: "dummy-child-model-title-1-value" },
                { id: nil, _destroy: false, title: "dummy-child-model-title-2-value" },
                { id: nil, _destroy: false, title: "dummy-child-model-title-3-value" }
              ]
            }
          )
        )

        expect {
          click_button "Submit me!"
          expect(page).to have_content("success!") # required to work properly!
          # expect proper form reset (added items are kept, but value is resetted)
          expect(page).to have_selector('#dummy_model_title_input')
          expect(page).to have_selector('#title_dummy_child_models_attributes_child_0')
          expect(page).to have_selector('#title_dummy_child_models_attributes_child_1')
          expect(page).to have_selector('#title_dummy_child_models_attributes_child_2')
          expect(page).to have_selector('#title_dummy_child_models_attributes_child_3')
          expect(page.find("#dummy_model_title_input").value).to eq("")
          expect(page.find("#title_dummy_child_models_attributes_child_0").value).to eq("init-value")
          expect(page.find("#title_dummy_child_models_attributes_child_1").value).to eq("")
          expect(page.find("#title_dummy_child_models_attributes_child_2").value).to eq("")
          expect(page.find("#title_dummy_child_models_attributes_child_3").value).to eq("")
        }
        .to change { DummyModel.count }.by(1)
        .and change { DummyChildModel.count }.by(4)
      end

      it "dynamically adds unlimited new nested forms properly initialized/resetted to AR Model init value" do
        class ExamplePage < Matestack::Ui::Page

          def prepare
            @dummy_model = DummyModel.new
            @dummy_model.dummy_child_models.build(title: "init-value-1")
            @dummy_model.dummy_child_models.build(title: "init-value-2")
          end


          def dummy_child_model_form dummy_child_model = DummyChildModel.new(title: "init-value-for-prototype")
            form_fields_for dummy_child_model, key: :dummy_child_models_attributes do
              form_input key: :title, type: :text, label: "dummy-child-model-title-input"
              form_fields_for_remove_item do
                button "remove", ":id": "'remove'+nestedFormRuntimeId", type: :button # id is just required in this spec, but type: :button is important! otherwise remove on first item is triggered on enter
              end
            end
          end

        end
        visit "/example"
        # sleep

        click_on "add"
        click_on "add"
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_2')
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_3')

        fill_in "dummy_model_title_input", with: "dummy-model-title-value"

        expect(page.find("#title_dummy_child_models_attributes_child_0").value).to eq("init-value-1")
        expect(page.find("#title_dummy_child_models_attributes_child_1").value).to eq("init-value-2")
        expect(page.find("#title_dummy_child_models_attributes_child_2").value).to eq("init-value-for-prototype")
        expect(page.find("#title_dummy_child_models_attributes_child_3").value).to eq("init-value-for-prototype")

        fill_in "title_dummy_child_models_attributes_child_3", with: "init-value-for-prototype-overwritten"

        expect_any_instance_of(NestedFormTestController).to receive(:expect_params)
          .with(
            hash_including(dummy_model: {
              title: 'dummy-model-title-value',
              dummy_child_models_attributes: [
                { id: nil, _destroy: false, title: "init-value-1" },
                { id: nil, _destroy: false, title: "init-value-2" },
                { id: nil, _destroy: false, title: "init-value-for-prototype" },
                { id: nil, _destroy: false, title: "init-value-for-prototype-overwritten" }
              ]
            }
          )
        )

        expect {
          click_button "Submit me!"
          expect(page).to have_content("success!") # required to work properly!
          # expect proper form reset (added items are kept, but value is resetted)
          expect(page.find("#dummy_model_title_input").value).to eq("")
          expect(page.find("#title_dummy_child_models_attributes_child_0").value).to eq("init-value-1")
          expect(page.find("#title_dummy_child_models_attributes_child_1").value).to eq("init-value-2")
          expect(page.find("#title_dummy_child_models_attributes_child_2").value).to eq("init-value-for-prototype")
          expect(page.find("#title_dummy_child_models_attributes_child_3").value).to eq("init-value-for-prototype")
        }
        .to change { DummyModel.count }.by(1)
        .and change { DummyChildModel.count }.by(4)
      end

      it "dynamically adds unlimited new nested forms properly without any child model present initially" do
        class ExamplePage < Matestack::Ui::Page
          def prepare
            @dummy_model = DummyModel.new
          end
        end

        visit "/example"

        expect(page).not_to have_selector('#title_dummy_child_models_attributes_child_0')
        expect(page).not_to have_selector('#title_dummy_child_models_attributes_child_1')
        click_on "add"
        click_on "add"
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_0')
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_1')

        fill_in "dummy_model_title_input", with: "dummy-model-title-value"

        fill_in "title_dummy_child_models_attributes_child_0", with: "dummy-child-model-title-0-value"
        fill_in "title_dummy_child_models_attributes_child_1", with: "dummy-child-model-title-1-value"

        expect_any_instance_of(NestedFormTestController).to receive(:expect_params)
          .with(
            hash_including(dummy_model: {
              title: 'dummy-model-title-value',
              dummy_child_models_attributes: [
                { id: nil, _destroy: false, title: "dummy-child-model-title-0-value" },
                { id: nil, _destroy: false, title: "dummy-child-model-title-1-value" }
              ]
            }
          )
        )

        expect {
          click_button "Submit me!"
          expect(page).to have_content("success!") # required to work properly!
          # expect proper form reset (added items are kept, but value is resetted)
          expect(page.find("#dummy_model_title_input").value).to eq("")
          expect(page.find("#title_dummy_child_models_attributes_child_0").value).to eq("")
          expect(page.find("#title_dummy_child_models_attributes_child_1").value).to eq("")
        }
        .to change { DummyModel.count }.by(1)
        .and change { DummyChildModel.count }.by(2)
      end

      it "dynamically adds unlimited new nested forms and maps errors properly" do
        visit "/example"
        # sleep

        click_on "add"
        click_on "add"
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_2')
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_3')

        fill_in "dummy_model_title_input", with: "" # required input, trigger server validation
        # fill_in "title_dummy_child_models_attributes_child_0", with: "" # via init value
        fill_in "title_dummy_child_models_attributes_child_1", with: "dummy-child-model-title-1-value"
        fill_in "title_dummy_child_models_attributes_child_2", with: "" # required input, trigger server validation
        fill_in "title_dummy_child_models_attributes_child_3", with: "dummy-child-model-title-3-value"

        click_button "Submit me!"
        expect(page).to have_content("failure!") # required to work properly!

        expect(page).to have_selector("#dummy_model_title_input + .errors > .error", text: "can't be blank")
        expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_0 + .errors > .error", text: "can't be blank")
        expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_1 + .errors > .error", text: "can't be blank")
        expect(page).to have_selector("#title_dummy_child_models_attributes_child_2 + .errors > .error", text: "can't be blank")
        expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_3 + .errors > .error", text: "can't be blank")

        # fill in missing values
        fill_in "dummy_model_title_input", with: "dummy-model-title-value"
        fill_in "title_dummy_child_models_attributes_child_2", with: "dummy-child-model-title-2-value"

        # defocus input in order to trigger errors to disappear
        page.find("#title_dummy_child_models_attributes_child_2").native.send_keys :tab

        #expect errors to disappear
        expect(page).not_to have_selector("#dummy_model_title_input + .errors > .error", text: "can't be blank")
        expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_0 + .errors > .error", text: "can't be blank")
        expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_1 + .errors > .error", text: "can't be blank")
        expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_2 + .errors > .error", text: "can't be blank")
        expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_3 + .errors > .error", text: "can't be blank")

        # expect proper form submission
        expect {
          click_button "Submit me!"
          expect(page).to have_content("success!") # required to work properly!
        }
        .to change { DummyModel.count }.by(1)
        .and change { DummyChildModel.count }.by(4)
      end

      it "dynamically adds unlimited new nested forms and maps errors properly when nested forms are removed" do
        visit "/example"
        # sleep

        click_on "add"
        click_on "add"
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_2')
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_3')

        fill_in "dummy_model_title_input", with: "" # required input, trigger server validation
        # fill_in "title_dummy_child_models_attributes_child_0", with: "" # via init value
        fill_in "title_dummy_child_models_attributes_child_1", with: "" # required input, trigger server validation
        fill_in "title_dummy_child_models_attributes_child_2", with: "" # required input, trigger server validation
        fill_in "title_dummy_child_models_attributes_child_3", with: "dummy-child-model-title-3-value"

        click_button "Submit me!"
        expect(page).to have_content("failure!") # required to work properly!

        expect(page).to have_selector("#dummy_model_title_input + .errors > .error", text: "can't be blank")
        expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_0 + .errors > .error", text: "can't be blank")
        expect(page).to have_selector("#title_dummy_child_models_attributes_child_1 + .errors > .error", text: "can't be blank")
        expect(page).to have_selector("#title_dummy_child_models_attributes_child_2 + .errors > .error", text: "can't be blank")
        expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_3 + .errors > .error", text: "can't be blank")

        click_on("remove_dummy_child_models_attributes_child_1")

        expect(page).not_to have_content("failure!") #wait for last failure message to disappear

        click_button "Submit me!"
        expect(page).to have_content("failure!")

        expect(page).to have_selector("#dummy_model_title_input + .errors > .error", text: "can't be blank")
        expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_0 + .errors > .error", text: "can't be blank")
        expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_1 + .errors > .error", text: "can't be blank")
        expect(page).to have_selector("#title_dummy_child_models_attributes_child_2 + .errors > .error", text: "can't be blank")
        expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_3 + .errors > .error", text: "can't be blank")

        # fill in missing values
        fill_in "dummy_model_title_input", with: "dummy-model-title-value"
        fill_in "title_dummy_child_models_attributes_child_2", with: "dummy-child-model-title-2-value"

        # defocus input in order to trigger errors to disappear
        page.find("#title_dummy_child_models_attributes_child_2").native.send_keys :tab

        # expect errors to disappear
        expect(page).not_to have_selector("#dummy_model_title_input + .errors > .error", text: "can't be blank")
        expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_0 + .errors > .error", text: "can't be blank")
        expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_1 + .errors > .error", text: "can't be blank")
        expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_2 + .errors > .error", text: "can't be blank")
        expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_3 + .errors > .error", text: "can't be blank")

        expect(page).not_to have_content("failure!") # wait for last failure message to disappear

        # expect proper form submission
        expect {
          click_button "Submit me!"
          expect(page).to have_content("success!") # required to work properly!
        }
        .to change { DummyModel.count }.by(1)
        .and change { DummyChildModel.count }.by(3)
      end

      it "dynamically adds unlimited new nested forms and maps errors properly when nested forms are removed" do
        visit "/example"
        # sleep

        click_on "add"
        click_on "add"
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_2')
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_3')

        fill_in "dummy_model_title_input", with: "" # required input, trigger server validation
        # fill_in "title_dummy_child_models_attributes_child_0", with: "" # via init value
        fill_in "title_dummy_child_models_attributes_child_1", with: "" # required input, trigger server validation
        fill_in "title_dummy_child_models_attributes_child_2", with: "dummy-child-model-title-2-value"
        fill_in "title_dummy_child_models_attributes_child_3", with: "" # required input, trigger server validation

        click_on("remove_dummy_child_models_attributes_child_1")

        click_button "Submit me!"
        expect(page).to have_content("failure!") # required to work properly!

        expect(page).to have_selector("#dummy_model_title_input + .errors > .error", text: "can't be blank")
        expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_0 + .errors > .error", text: "can't be blank")
        expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_1 + .errors > .error", text: "can't be blank")
        expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_2 + .errors > .error", text: "can't be blank")
        expect(page).to have_selector("#title_dummy_child_models_attributes_child_3 + .errors > .error", text: "can't be blank")

        # expect proper form submission
        # expect {
        #   click_button "Submit me!"
        #   expect(page).to have_content("success!") # required to work properly!
        # }
        # .to change { DummyModel.count }.by(1)
        # .and change { DummyChildModel.count }.by(3)
      end


    end

    describe "supports removal/edition of nested forms/models for EXISTING instances" do

      before do
        @dummy_model = DummyModel.create(title: "existing-dummy-model-title")
        @dummy_model.dummy_child_models.create(title: "existing-dummy-child-model-title-1")
        @dummy_model.dummy_child_models.create(title: "existing-dummy-child-model-title-2")

        class ExamplePage < Matestack::Ui::Page

          def prepare
            @dummy_model = DummyModel.last
          end

          def response
            matestack_form form_config do
              form_input key: :title, type: :text, label: "dummy_model_title_input", id: "dummy_model_title_input"

              @dummy_model.dummy_child_models.each do |dummy_child_model|
                dummy_child_model_form dummy_child_model
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
                button "remove", ":id": "'remove'+nestedFormRuntimeId", type: :button # id is just required in this spec, but type: :button is important! otherwise remove on first item is triggered on enter
              end
            end
          end

          def form_config
            {
              for: @dummy_model,
              method: :put,
              path: nested_forms_spec_submit_update_path(id: @dummy_model.id),
              success: { emit: "success" },
              failure: { emit: "failure" }
            }
          end
        end
      end

      it "submits properly with _destroy: true on each element which was removed and triggers removal/update in DB" do
        id_of_child_1 = DummyChildModel.last.id
        id_of_child_0 = id_of_child_1-1

        visit "/example"

        expect(page.find("#dummy_model_title_input").value).to eq("existing-dummy-model-title")
        expect(page.find("#title_dummy_child_models_attributes_child_0").value).to eq("existing-dummy-child-model-title-1")
        expect(page.find("#title_dummy_child_models_attributes_child_1").value).to eq("existing-dummy-child-model-title-2")

        click_on("remove_dummy_child_models_attributes_child_0")
        fill_in "title_dummy_child_models_attributes_child_1", with: "existing-dummy-child-model-title-2-new-value"

        expect(page).to have_selector('#dummy_model_title_input')
        expect(page).not_to have_selector('#title_dummy_child_models_attributes_child_0')
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_1')

        expect_any_instance_of(NestedFormTestController).to receive(:expect_params)
          .with(
            hash_including(dummy_model: {
              title: 'existing-dummy-model-title',
              dummy_child_models_attributes: [
                { id: id_of_child_0.to_s, _destroy: true, title: "existing-dummy-child-model-title-1" },
                { id: id_of_child_1.to_s, _destroy: false, title: "existing-dummy-child-model-title-2-new-value" }
              ]
            }
          )
        )

        expect {
          click_button "Submit me!"
          expect(page).to have_content("success!") # required to work properly!
          expect(page).not_to have_selector('#title_dummy_child_models_attributes_child_0')
          expect(page.find("#dummy_model_title_input").value).to eq("existing-dummy-model-title")
          expect(page.find("#title_dummy_child_models_attributes_child_1").value).to eq("existing-dummy-child-model-title-2-new-value")
        }
        .to change { DummyModel.count }.by(0)
        .and change { DummyChildModel.count }.by(-1)

        expect(DummyChildModel.find(id_of_child_1).title).to eq("existing-dummy-child-model-title-2-new-value")
      end

      it "maps errors properly back" do
        id_of_child_1 = DummyChildModel.last.id
        id_of_child_0 = id_of_child_1-1

        visit "/example"
        # sleep

        expect(page.find("#dummy_model_title_input").value).to eq("existing-dummy-model-title")
        expect(page.find("#title_dummy_child_models_attributes_child_0").value).to eq("existing-dummy-child-model-title-1")
        expect(page.find("#title_dummy_child_models_attributes_child_1").value).to eq("existing-dummy-child-model-title-2")

        fill_in "title_dummy_child_models_attributes_child_1", with: "", fill_options: { clear: :backspace } # trigger server validation

        click_on("remove_dummy_child_models_attributes_child_0")

        expect {
          click_button "Submit me!"
          expect(page).to have_content("failure!") # required to work properly!

          expect(page).not_to have_selector('#title_dummy_child_models_attributes_child_0')
          expect(page).not_to have_selector("#dummy_model_title_input + .errors > .error", text: "can't be blank")
          expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_0 + .errors > .error", text: "can't be blank")
          expect(page).to have_selector("#title_dummy_child_models_attributes_child_1 + .errors > .error", text: "can't be blank")
        }
        .to change { DummyModel.count }.by(0)
        .and change { DummyChildModel.count }.by(0)

        expect(DummyChildModel.find(id_of_child_1).title).to eq("existing-dummy-child-model-title-2")
      end

    end

    describe "supports addition of nested forms/models on top of EXISTING instances" do

      before do
        @dummy_model = DummyModel.create(title: "existing-dummy-model-title")
        @dummy_model.dummy_child_models.create(title: "existing-dummy-child-model-title-1")
        @dummy_model.dummy_child_models.create(title: "existing-dummy-child-model-title-2")

        class ExamplePage < Matestack::Ui::Page

          def prepare
            @dummy_model = DummyModel.last
          end

          def response
            matestack_form form_config do
              form_input key: :title, type: :text, label: "dummy_model_title_input", id: "dummy_model_title_input"

              @dummy_model.dummy_child_models.each do |dummy_child_model|
                dummy_child_model_form dummy_child_model
              end

              form_fields_for_add_item key: :dummy_child_models_attributes, prototype: method(:dummy_child_model_form) do
                button "add", type: :button # type: :button is important! otherwise remove on first item is triggered on enter
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
                button "remove", ":id": "'remove'+nestedFormRuntimeId", type: :button # id is just required in this spec, but type: :button is important! otherwise remove on first item is triggered on enter
              end
            end
          end

          def form_config
            {
              for: @dummy_model,
              method: :put,
              path: nested_forms_spec_submit_update_path(id: @dummy_model.id),
              success: { emit: "success" },
              failure: { emit: "failure" }
            }
          end
        end
      end

      it "dynamically adds unlimited new nested forms and submits/resets all data properly" do
        id_of_child_1 = DummyChildModel.last.id
        id_of_child_0 = id_of_child_1-1

        visit "/example"
        # sleep
        expect(page).to have_selector('#dummy_model_title_input')
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_0')
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_1')
        expect(page).not_to have_selector('#title_dummy_child_models_attributes_child_2')
        expect(page).not_to have_selector('#title_dummy_child_models_attributes_child_3')

        click_on "add"
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_2')
        click_on "add"
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_3')


        fill_in "title_dummy_child_models_attributes_child_2", with: "new-dummy-child-model-title-3-value"
        fill_in "title_dummy_child_models_attributes_child_3", with: "new-dummy-child-model-title-4-value"

        expect_any_instance_of(NestedFormTestController).to receive(:expect_params)
          .with(
            hash_including(dummy_model: {
              title: 'existing-dummy-model-title',
              dummy_child_models_attributes: [
                { id: id_of_child_0.to_s, _destroy: false, title: "existing-dummy-child-model-title-1" },
                { id: id_of_child_1.to_s, _destroy: false, title: "existing-dummy-child-model-title-2" },
                { id: nil, _destroy: false, title: "new-dummy-child-model-title-3-value" },
                { id: nil, _destroy: false, title: "new-dummy-child-model-title-4-value" }
              ]
            }
          )
        )

        expect {
          click_button "Submit me!"
          expect(page).to have_content("success!") # required to work properly!
          # expect proper form reset (added items are kept, but value is resetted)
          expect(page).to have_selector('#dummy_model_title_input')
          expect(page).to have_selector('#title_dummy_child_models_attributes_child_0')
          expect(page).to have_selector('#title_dummy_child_models_attributes_child_1')
          expect(page).to have_selector('#title_dummy_child_models_attributes_child_2')
          expect(page).to have_selector('#title_dummy_child_models_attributes_child_3')
          expect(page.find("#dummy_model_title_input").value).to eq("existing-dummy-model-title")
          expect(page.find("#title_dummy_child_models_attributes_child_0").value).to eq("existing-dummy-child-model-title-1")
          expect(page.find("#title_dummy_child_models_attributes_child_1").value).to eq("existing-dummy-child-model-title-2")
          expect(page.find("#title_dummy_child_models_attributes_child_2").value).to eq("new-dummy-child-model-title-3-value")
          expect(page.find("#title_dummy_child_models_attributes_child_3").value).to eq("new-dummy-child-model-title-4-value")
        }
        .to change { DummyModel.count }.by(0)
        .and change { DummyChildModel.count }.by(2)
      end

      it "dynamically adds unlimited new nested forms and maps errors properly back" do
        visit "/example"

        expect(page).to have_selector('#dummy_model_title_input')
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_0')
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_1')
        expect(page).not_to have_selector('#title_dummy_child_models_attributes_child_2')
        expect(page).not_to have_selector('#title_dummy_child_models_attributes_child_3')
        expect(page).not_to have_selector('#title_dummy_child_models_attributes_child_4')

        click_on "add"
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_2')
        click_on "add"
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_3')
        click_on "add"
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_4')

        fill_in "title_dummy_child_models_attributes_child_0", with: "", fill_options: { clear: :backspace } # trigger server validation
        # fill_in "title_dummy_child_models_attributes_child_1", with: "" # via init value
        fill_in "title_dummy_child_models_attributes_child_2", with: "" # would trigger but will be removed
        fill_in "title_dummy_child_models_attributes_child_3", with: "" # trigger server validation
        fill_in "title_dummy_child_models_attributes_child_4", with: "new-dummy-child-model-title-3-value"

        click_on("remove_dummy_child_models_attributes_child_2")

        expect {
          click_button "Submit me!"
          expect(page).to have_content("failure!") # required to work properly!
          expect(page).not_to have_selector("#dummy_model_title_input + .errors > .error", text: "can't be blank")
          expect(page).to have_selector("#title_dummy_child_models_attributes_child_0 + .errors > .error", text: "can't be blank")
          expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_1 + .errors > .error", text: "can't be blank")
          expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_2 + .errors > .error", text: "can't be blank")
          expect(page).to have_selector("#title_dummy_child_models_attributes_child_3 + .errors > .error", text: "can't be blank")
          expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_4 + .errors > .error", text: "can't be blank")
        }
        .to change { DummyModel.count }.by(0)
        .and change { DummyChildModel.count }.by(0)

        expect(page).not_to have_content("failure!") # wait for last failure message to disappear

        click_on("remove_dummy_child_models_attributes_child_0")

        expect {
          click_button "Submit me!"
          expect(page).to have_content("failure!") # required to work properly!
          expect(page).not_to have_selector("#dummy_model_title_input + .errors > .error", text: "can't be blank")
          expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_0 + .errors > .error", text: "can't be blank")
          expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_1 + .errors > .error", text: "can't be blank")
          expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_2 + .errors > .error", text: "can't be blank")
          expect(page).to have_selector("#title_dummy_child_models_attributes_child_3 + .errors > .error", text: "can't be blank")
          expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_4 + .errors > .error", text: "can't be blank")
        }
        .to change { DummyModel.count }.by(0)
        .and change { DummyChildModel.count }.by(0)

        expect(page).not_to have_content("failure!") # wait for last failure message to disappear

        click_on("remove_dummy_child_models_attributes_child_3")

        expect {
          click_button "Submit me!"
          expect(page).to have_content("success!") # required to work properly!
          expect(page).not_to have_selector("#dummy_model_title_input + .errors > .error", text: "can't be blank")
          expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_0 + .errors > .error", text: "can't be blank")
          expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_1 + .errors > .error", text: "can't be blank")
          expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_2 + .errors > .error", text: "can't be blank")
          expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_3 + .errors > .error", text: "can't be blank")
          expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_4 + .errors > .error", text: "can't be blank")
        }
        .to change { DummyModel.count }.by(0)
        .and change { DummyChildModel.count }.by(0) # added one and removed one

        expect(DummyChildModel.last.title).to eq("new-dummy-child-model-title-3-value")
      end

      it "dynamically adds unlimited new nested forms and maps errors properly back and properly resets errors when missing value is provided" do

        class ExamplePage < Matestack::Ui::Page

          def response
            matestack_form form_config do
              form_input key: :title, type: :text, label: "dummy_model_title_input", id: "dummy_model_title_input"

              @dummy_model.dummy_child_models.each do |dummy_child_model|
                dummy_child_model_form dummy_child_model
              end

              form_fields_for_add_item key: :dummy_child_models_attributes, prototype: method(:dummy_child_model_form) do
                button "add", type: :button # type: :button is important! otherwise remove on first item is triggered on enter
              end

              button "Submit me!"

              plain "Errors: {{errors}}"

              toggle show_on: "success", hide_after: 1000 do
                plain "success!"
              end
              toggle show_on: "failure", hide_after: 1000 do
                plain "failure!"
              end
            end
          end

        end

        visit "/example"
        # sleep

        click_on "add"
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_2')
        click_on "add"
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_3')

        fill_in "title_dummy_child_models_attributes_child_0", with: "", fill_options: { clear: :backspace } # trigger server validation
        # fill_in "title_dummy_child_models_attributes_child_1", with: "" # via init value
        fill_in "title_dummy_child_models_attributes_child_2", with: "" # would trigger but will be removed
        fill_in "title_dummy_child_models_attributes_child_3", with: "" # trigger server validation

        click_on("remove_dummy_child_models_attributes_child_2")

        click_button "Submit me!"
        expect(page).to have_content("failure!") # required to work properly!

        expect(page).to have_selector("#title_dummy_child_models_attributes_child_0 + .errors > .error", text: "can't be blank")
        expect(page).to have_selector("#title_dummy_child_models_attributes_child_3 + .errors > .error", text: "can't be blank")

        expect(page).to have_content('Errors: { "dummy_child_models[0].title": [ "can\'t be blank" ], "dummy_child_models[2].title": [ "can\'t be blank" ] }')

        fill_in "title_dummy_child_models_attributes_child_3", with: "some-value" # provide missing input and reset error
        # defocus input in order to trigger errors to disappear
        page.find("#title_dummy_child_models_attributes_child_3").native.send_keys :tab

        expect(page).to have_selector("#title_dummy_child_models_attributes_child_0 + .errors > .error", text: "can't be blank")
        expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_3 + .errors > .error", text: "can't be blank")

        expect(page).to have_content('Errors: { "dummy_child_models[0].title": [ "can\'t be blank" ]')
        expect(page).not_to have_content('Errors: { "dummy_child_models[0].title": [ "can\'t be blank" ], "dummy_child_models[2].title": [ "can\'t be blank" ] }')
      end

      it "dynamically adds unlimited new nested forms and maps errors properly back and properly resets errors when errornous item is removed" do

        class ExamplePage < Matestack::Ui::Page

          def response
            matestack_form form_config do
              form_input key: :title, type: :text, label: "dummy_model_title_input", id: "dummy_model_title_input"

              @dummy_model.dummy_child_models.each do |dummy_child_model|
                dummy_child_model_form dummy_child_model
              end

              form_fields_for_add_item key: :dummy_child_models_attributes, prototype: method(:dummy_child_model_form) do
                button "add", type: :button # type: :button is important! otherwise remove on first item is triggered on enter
              end

              button "Submit me!"

              plain "Errors: {{errors}}"

              toggle show_on: "success", hide_after: 1000 do
                plain "success!"
              end
              toggle show_on: "failure", hide_after: 1000 do
                plain "failure!"
              end
            end
          end

        end

        visit "/example"

        click_on "add"
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_2')
        click_on "add"
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_3')

        fill_in "title_dummy_child_models_attributes_child_0", with: "", fill_options: { clear: :backspace } # trigger server validation
        # fill_in "title_dummy_child_models_attributes_child_1", with: "" # via init value
        fill_in "title_dummy_child_models_attributes_child_2", with: "" # would trigger but will be removed
        fill_in "title_dummy_child_models_attributes_child_3", with: "" # trigger server validation

        click_on("remove_dummy_child_models_attributes_child_2")

        click_button "Submit me!"
        expect(page).to have_content("failure!") # required to work properly!

        expect(page).to have_selector("#title_dummy_child_models_attributes_child_0 + .errors > .error", text: "can't be blank")
        expect(page).to have_selector("#title_dummy_child_models_attributes_child_3 + .errors > .error", text: "can't be blank")

        expect(page).to have_content('Errors: { "dummy_child_models[0].title": [ "can\'t be blank" ], "dummy_child_models[2].title": [ "can\'t be blank" ] }')

        click_on("remove_dummy_child_models_attributes_child_3") # remove element which causes errors

        expect(page).to have_selector("#title_dummy_child_models_attributes_child_0 + .errors > .error", text: "can't be blank")
        expect(page).not_to have_selector("#title_dummy_child_models_attributes_child_3 + .errors > .error", text: "can't be blank")

        expect(page).to have_content('Errors: { "dummy_child_models[0].title": [ "can\'t be blank" ]')
        expect(page).not_to have_content('Errors: { "dummy_child_models[0].title": [ "can\'t be blank" ], "dummy_child_models[2].title": [ "can\'t be blank" ] }')
      end


    end

    describe "supports multipart form submit alongside file upload within parent model" do

      before do
        @dummy_model = DummyModel.create(title: "existing-dummy-model-title")
        @dummy_model.dummy_child_models.create(title: "existing-dummy-child-model-title-1")
        @dummy_model.dummy_child_models.create(title: "existing-dummy-child-model-title-2")

        class ExamplePage < Matestack::Ui::Page

          def prepare
            @dummy_model = DummyModel.last
          end

          def response
            matestack_form form_config do
              form_input key: :title, type: :text, label: "dummy_model_title_input", id: "dummy_model_title_input"

              form_input key: :file, type: :file, label: "dummy_model_file_input", id: "dummy_model_file_input"
              form_input key: :files, type: :file, label: "dummy_model_files_input", id: "dummy_model_files_input", multiple: true

              @dummy_model.dummy_child_models.each do |dummy_child_model|
                dummy_child_model_form dummy_child_model
              end

              form_fields_for_add_item key: :dummy_child_models_attributes, prototype: method(:dummy_child_model_form) do
                button "add", type: :button # type: :button is important! otherwise remove on first item is triggered on enter
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
              form_input key: :file, type: :file, label: "dummy-child-model-file-input"
              form_input key: :files, type: :file, label: "dummy-child-model-files-input", multiple: true

              form_fields_for_remove_item do
                button "remove", ":id": "'remove'+nestedFormRuntimeId", type: :button # id is just required in this spec, but type: :button is important! otherwise remove on first item is triggered on enter
              end
            end
          end

          def form_config
            {
              for: @dummy_model,
              method: :put,
              multipart: true,
              path: nested_forms_spec_submit_update_path(id: @dummy_model.id),
              success: { emit: "success" },
              failure: { emit: "failure" }
            }
          end
        end
      end

      it "and properly sends dynamically added child data as multipart format" do
        id_of_parent = DummyModel.last.id
        id_of_child_1 = DummyChildModel.last.id
        id_of_child_0 = id_of_child_1-1

        visit "/example"

        expect(page).to have_selector('#dummy_model_title_input')
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_0')
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_1')
        expect(page).not_to have_selector('#title_dummy_child_models_attributes_child_2')
        expect(page).not_to have_selector('#title_dummy_child_models_attributes_child_3')

        click_on "add"
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_2')
        click_on "add"
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_3')


        fill_in "title_dummy_child_models_attributes_child_2", with: "new-dummy-child-model-title-3-value"
        fill_in "title_dummy_child_models_attributes_child_3", with: "new-dummy-child-model-title-4-value"

        attach_file('dummy_model_file_input', "#{File.dirname(__FILE__)}/input/test_files/matestack-logo.png")
        attach_file "dummy_model_files_input", ["#{File.dirname(__FILE__)}/input/test_files/matestack-logo.png", "#{File.dirname(__FILE__)}/input/test_files/corgi.mp4"]

        attach_file('file_dummy_child_models_attributes_child_0', "#{File.dirname(__FILE__)}/input/test_files/matestack-logo.png")
        attach_file('file_dummy_child_models_attributes_child_2', "#{File.dirname(__FILE__)}/input/test_files/corgi.mp4")
        attach_file('file_dummy_child_models_attributes_child_3', "#{File.dirname(__FILE__)}/input/test_files/matestack-logo.png")

        attach_file "files_dummy_child_models_attributes_child_0", ["#{File.dirname(__FILE__)}/input/test_files/matestack-logo.png", "#{File.dirname(__FILE__)}/input/test_files/corgi.mp4"]
        attach_file "files_dummy_child_models_attributes_child_2", ["#{File.dirname(__FILE__)}/input/test_files/matestack-logo.png", "#{File.dirname(__FILE__)}/input/test_files/corgi.mp4"]
        attach_file "files_dummy_child_models_attributes_child_3", ["#{File.dirname(__FILE__)}/input/test_files/matestack-logo.png", "#{File.dirname(__FILE__)}/input/test_files/corgi.mp4"]

        expect {
          click_button "Submit me!"
          expect(page).to have_content("success!") # required to work properly!
          # expect proper form reset (added items are kept, but value is resetted)
          expect(page).to have_selector('#dummy_model_title_input')
          expect(page).to have_selector('#title_dummy_child_models_attributes_child_0')
          expect(page).to have_selector('#title_dummy_child_models_attributes_child_1')
          expect(page).to have_selector('#title_dummy_child_models_attributes_child_2')
          expect(page).to have_selector('#title_dummy_child_models_attributes_child_3')
          expect(page.find("#dummy_model_title_input").value).to eq("existing-dummy-model-title")
          expect(page.find("#title_dummy_child_models_attributes_child_0").value).to eq("existing-dummy-child-model-title-1")
          expect(page.find("#title_dummy_child_models_attributes_child_1").value).to eq("existing-dummy-child-model-title-2")
          expect(page.find("#title_dummy_child_models_attributes_child_2").value).to eq("new-dummy-child-model-title-3-value")
          expect(page.find("#title_dummy_child_models_attributes_child_3").value).to eq("new-dummy-child-model-title-4-value")
        }
        .to change { DummyModel.count }.by(0)
        .and change { DummyChildModel.count }.by(2)

        id_of_child_3 = DummyChildModel.last.id
        id_of_child_2 = id_of_child_3-1

        expect(DummyChildModel.find(id_of_child_3).title).to eq("new-dummy-child-model-title-4-value")
        expect(DummyChildModel.find(id_of_child_2).title).to eq("new-dummy-child-model-title-3-value")

        expect(DummyModel.find(id_of_parent).file.blob.filename).to eq("matestack-logo.png")
        expect(DummyModel.find(id_of_parent).files[0].blob.filename).to eq("matestack-logo.png")
        expect(DummyModel.find(id_of_parent).files[1].blob.filename).to eq("corgi.mp4")

        expect(DummyChildModel.find(id_of_child_0).file.blob.filename).to eq("matestack-logo.png")
        expect(DummyChildModel.find(id_of_child_0).files[0].blob.filename).to eq("matestack-logo.png")
        expect(DummyChildModel.find(id_of_child_0).files[1].blob.filename).to eq("corgi.mp4")

        expect(DummyChildModel.find(id_of_child_1).file.attached?).to be false
        expect(DummyChildModel.find(id_of_child_1).files.attached?).to be false

        expect(DummyChildModel.find(id_of_child_2).file.blob.filename).to eq("corgi.mp4")
        expect(DummyChildModel.find(id_of_child_2).files[0].blob.filename).to eq("matestack-logo.png")
        expect(DummyChildModel.find(id_of_child_2).files[1].blob.filename).to eq("corgi.mp4")

        expect(DummyChildModel.find(id_of_child_3).file.blob.filename).to eq("matestack-logo.png")
        expect(DummyChildModel.find(id_of_child_3).files[0].blob.filename).to eq("matestack-logo.png")
        expect(DummyChildModel.find(id_of_child_3).files[1].blob.filename).to eq("corgi.mp4")
      end

    end

    describe "supports addition of nested forms/models on top of EXISTING instances" do

      before do
        @dummy_model = DummyModel.create(title: "existing-dummy-model-title")

        class ExamplePage < Matestack::Ui::Page

          def prepare
            @dummy_model = DummyModel.last
          end

          def response
            matestack_form form_config do
              form_input key: :title, type: :text, label: "dummy_model_title_input", id: "dummy_model_title_input"

              @dummy_model.dummy_child_models.each do |dummy_child_model|
                dummy_child_model_form dummy_child_model
              end

              form_fields_for_add_item key: :dummy_child_models_attributes, prototype: method(:dummy_child_model_form) do
                button "add", type: :button # type: :button is important! otherwise remove on first item is triggered on enter
              end

              br
              plain "data: {{data}}"
              br

              button "Submit me!"

              toggle show_on: "success", hide_after: 1000 do
                plain "success!"
              end
              toggle show_on: "failure", hide_after: 1000 do
                plain "failure!"
              end
            end
          end

          def dummy_child_model_form dummy_child_model = DummyChildModel.new(title: "init-value")
            form_fields_for dummy_child_model, key: :dummy_child_models_attributes do
              form_input key: :title, type: :text, label: "dummy-child-model-title-input"
              form_fields_for_remove_item do
                button "remove", ":id": "'remove'+nestedFormRuntimeId", type: :button # id is just required in this spec, but type: :button is important! otherwise remove on first item is triggered on enter
              end
            end
          end

          def form_config
            {
              for: @dummy_model,
              method: :put,
              path: nested_forms_spec_submit_update_path(id: @dummy_model.id),
              success: { emit: "success" },
              failure: { emit: "failure" }
            }
          end
        end
      end

      it "dynamically adds unlimited new nested forms and enable proper clientside data binding" do

        visit "/example"
        # sleep
        expect(page).to have_selector('#dummy_model_title_input')
        expect(page).not_to have_selector('#title_dummy_child_models_attributes_child_0')
        expect(page).not_to have_selector('#title_dummy_child_models_attributes_child_1')

        expect(page).to have_content('data: { "title": "existing-dummy-model-title" }')

        click_on "add"
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_0')

        expect(page).to have_content('data: { "title": "existing-dummy-model-title", "dummy_child_models_attributes": [ { "_destroy": false, "id": null, "title": "init-value" } ] }')

        click_on "add"
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_1')

        expect(page).to have_content('data: { "title": "existing-dummy-model-title", "dummy_child_models_attributes": [ { "_destroy": false, "id": null, "title": "init-value" }, { "_destroy": false, "id": null, "title": "init-value" } ] }')

        fill_in "title_dummy_child_models_attributes_child_1", with: "new-value"

        expect(page).to have_content('data: { "title": "existing-dummy-model-title", "dummy_child_models_attributes": [ { "_destroy": false, "id": null, "title": "init-value" }, { "_destroy": false, "id": null, "title": "new-value" } ] }')

        click_on("remove_dummy_child_models_attributes_child_0")

        expect(page).to have_content('data: { "title": "existing-dummy-model-title", "dummy_child_models_attributes": [ { "_destroy": true, "id": null, "title": "init-value" }, { "_destroy": false, "id": null, "title": "new-value" } ] }')
      end

      it "dynamically adds unlimited new nested forms and enable proper clientside data binding with initially present child models" do

        dummy_model = DummyModel.last
        child_model_0 = dummy_model.dummy_child_models.create(title: "existing-child-model-title")

        visit "/example"
        # sleep
        expect(page).to have_selector('#dummy_model_title_input')
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_0')
        expect(page).not_to have_selector('#title_dummy_child_models_attributes_child_1')

        expect(page).to have_content("data: { \"dummy_child_models_attributes\": [ { \"_destroy\": false, \"id\": \"#{child_model_0.id}\", \"title\": \"existing-child-model-title\" } ], \"title\": \"existing-dummy-model-title\" }")

        click_on "add"
        expect(page).to have_selector('#title_dummy_child_models_attributes_child_1')

        expect(page).to have_content("data: { \"dummy_child_models_attributes\": [ { \"_destroy\": false, \"id\": \"#{child_model_0.id}\", \"title\": \"existing-child-model-title\" }, { \"_destroy\": false, \"id\": null, \"title\": \"init-value\" } ], \"title\": \"existing-dummy-model-title\" }")

        fill_in "title_dummy_child_models_attributes_child_1", with: "new-value"

        expect(page).to have_content("data: { \"dummy_child_models_attributes\": [ { \"_destroy\": false, \"id\": \"#{child_model_0.id}\", \"title\": \"existing-child-model-title\" }, { \"_destroy\": false, \"id\": null, \"title\": \"new-value\" } ], \"title\": \"existing-dummy-model-title\" }")

        click_on("remove_dummy_child_models_attributes_child_0")

        expect(page).to have_content("data: { \"dummy_child_models_attributes\": [ { \"_destroy\": true, \"id\": \"#{child_model_0.id}\", \"title\": \"existing-child-model-title\" }, { \"_destroy\": false, \"id\": null, \"title\": \"new-value\" } ], \"title\": \"existing-dummy-model-title\" }")
      end

    end

  end

end
