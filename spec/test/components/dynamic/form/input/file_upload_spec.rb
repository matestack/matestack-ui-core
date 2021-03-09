require_relative "../../../../support/utils"
require_relative "../../../../support/test_controller"
require_relative "../support/form_test_controller"
require_relative "../support/model_form_test_controller"
include Utils

describe "Form Component", type: :feature, js: true do

  before :all do
    class UploadFormTestController < FormTestController
      def success_submit
        render json: {
          title: "server received title: #{form_params[:title].to_s}",
          file_1: {
            instance: "server received file_1 instance: #{form_params[:file_1] ||= 'nil'}",
            name: "server received file_1 with name: #{form_params[:file_1].present? ? form_params[:file_1].original_filename : 'nil'}"
          },
          file_2: {
            instance: "server received file_2 instance: #{form_params[:file_2] ||= 'nil'}",
            name: "server received file_2 with name: #{form_params[:file_2].present? ? form_params[:file_2].original_filename : 'nil'}"
          },
          files: [
            {
              instance: "server received files[0] instance: #{form_params[:files].present? ? form_params[:files][0] : 'nil'}",
              name: "server received files[0] with name: #{form_params[:files].present? ? form_params[:files][0].original_filename : 'nil'}"
            },
            {
              instance: "server received files[1] instance: #{form_params[:files].present? ? form_params[:files][1] : 'nil'}",
              name: "server received files[1] with name: #{form_params[:files].present? ? form_params[:files][1].original_filename : 'nil'}"
            }
          ]
        }, status: 200
      end

      def failure_submit
        render json: {
          message: "server says: form had errors",
          errors: { file: ["file seems to be invalid"], files: ["files seem to be invalid"] }
        }, status: 400
      end

      protected

      def form_params
        params.require(:my_form).permit(:title, :file_1, :file_2, files: [])
      end
    end

    Rails.application.routes.append do
      post '/file_upload_success_form_test', to: 'upload_form_test#success_submit', as: 'form_input_file_upload_success_form_test'
      post '/file_upload_failure_form_test', to: 'upload_form_test#failure_submit', as: 'form_input_file_upload_failure_form_test'
    end
    Rails.application.reload_routes!
  end

  before :each do
    allow_any_instance_of(UploadFormTestController).to receive(:expect_params)
  end

  describe "File Upload" do

    it "can upload (multiple) single files if multipart is set to true" do
      Object.send(:remove_const, :TestModel)
      class TestModel < ApplicationRecord
        has_one_attached :file
      end

      class ExamplePage < Matestack::Ui::Page
        def response
          m_form form_config do
            form_input key: :title, type: :text, placeholder: "title", id: "title-input"
            br
            form_input key: :file_1, type: :file, id: "file-1-input"
            br
            form_input key: :file_2, type: :file, id: "file-2-input"
            br
            form_input key: :files, type: :file, multiple: true, id: "files-input"
            br
            button 'Submit me!'
          end
          toggle show_on: "uploaded_successfully", id: 'async-form' do
            plain "{{event.data.title}}"
            plain "{{event.data.file_1.instance}}"
            plain "{{event.data.file_1.name}}"
            plain "{{event.data.file_2.instance}}"
            plain "{{event.data.file_2.name}}"
            plain "{{event.data.files}}"
          end
        end

        def form_config
          return {
            for: :my_form,
            method: :post,
            multipart: true,
            path: form_input_file_upload_success_form_test_path,
            success: {
              emit: "uploaded_successfully"
            }
          }
        end
      end

      visit '/example'
      fill_in "title-input", with: "bar"
      click_button "Submit me!"
      expect(page).to have_content("title: bar")
      expect(page).to have_content("file_1 instance: nil")
      expect(page).to have_content("file_1 with name: nil")
      expect(page).to have_content("file_2 instance: nil")
      expect(page).to have_content("file_2 with name: nil")
      expect(page).to have_content("files[0] instance: nil")
      expect(page).to have_content("files[1] instance: nil")
      expect(page).to have_content("files[0] with name: nil")
      expect(page).to have_content("files[1] with name: nil")

      visit '/example'
      fill_in "title-input", with: "bar"
      attach_file('file-1-input', "#{File.dirname(__FILE__)}/test_files/matestack-logo.png")
      click_button "Submit me!"
      expect(page).to have_content("title: bar")
      expect(page).to have_content("file_1 instance: #<ActionDispatch::Http::UploadedFile")
      expect(page).to have_content("file_1 with name: matestack-logo.png")
      expect(page).to have_content("file_2 instance: nil")
      expect(page).to have_content("file_2 with name: nil")
      expect(page).to have_content("files[0] instance: nil")
      expect(page).to have_content("files[1] instance: nil")
      expect(page).to have_content("files[0] with name: nil")
      expect(page).to have_content("files[1] with name: nil")

      visit '/example'
      fill_in "title-input", with: "bar"
      attach_file('file-1-input', "#{File.dirname(__FILE__)}/test_files/matestack-logo.png")
      attach_file('file-2-input', "#{File.dirname(__FILE__)}/test_files/corgi.mp4")
      click_button "Submit me!"
      expect(page).to have_content("title: bar")
      expect(page).to have_content("file_1 instance: #<ActionDispatch::Http::UploadedFile")
      expect(page).to have_content("file_1 with name: matestack-logo.png")
      expect(page).to have_content("file_2 instance: #<ActionDispatch::Http::UploadedFile")
      expect(page).to have_content("file_2 with name: ")
      expect(page).to have_content("files[0] instance: nil")
      expect(page).to have_content("files[1] instance: nil")
      expect(page).to have_content("files[0] with name: nil")
      expect(page).to have_content("files[1] with name: nil")


      visit '/example'
      fill_in "title-input", with: "bar"
      attach_file('file-1-input', "#{File.dirname(__FILE__)}/test_files/matestack-logo.png")
      attach_file('file-2-input', "#{File.dirname(__FILE__)}/test_files/corgi.mp4")
      attach_file "files-input", ["#{File.dirname(__FILE__)}/test_files/matestack-logo.png", "#{File.dirname(__FILE__)}/test_files/corgi.mp4"]
      click_button "Submit me!"
      expect(page).to have_content("title: bar")
      expect(page).to have_content("file_1 instance: #<ActionDispatch::Http::UploadedFile")
      expect(page).to have_content("file_1 with name: matestack-logo.png")
      expect(page).to have_content("file_2 instance: #<ActionDispatch::Http::UploadedFile")
      expect(page).to have_content("file_2 with name: corgi.mp4")
      expect(page).to have_content("files[0] instance: #<ActionDispatch::Http::UploadedFile")
      expect(page).to have_content("files[1] instance: #<ActionDispatch::Http::UploadedFile")
      expect(page).to have_content("files[0] with name: matestack-logo.png")
      expect(page).to have_content("files[1] with name: corgi.mp4")
    end

    it "is not initialized with any given file even if mapped to an AciveRecord Model" do
      Object.send(:remove_const, :TestModel)
      class TestModel < ApplicationRecord
        has_one_attached :file
      end

      class ExamplePage < Matestack::Ui::Page
        def response
          @test_model = TestModel.create title: "Foo", description: "This is a very nice foo!"
          @test_model.file.attach(io: File.open("#{File.dirname(__FILE__)}/test_files/matestack-logo.png"), filename: 'matestack-logo.png')
          m_form form_config do
            form_input key: :title, type: :text, placeholder: "title", id: "title-input"
            br
            form_input key: :file, type: :file, id: "file-1-input"
            br
            button 'Submit me!'
          end
        end

        def form_config
          return {
            for: @test_model,
            method: :post,
            multipart: true,
            path: form_input_file_upload_success_form_test_path,
            success: {
              emit: "uploaded_successfully"
            }
          }
        end
      end

      visit '/example'
      text_input_value = page.find('#title-input').value
      file_input_value = page.find('#file-1-input').value
      expect(text_input_value).to eq("Foo")
      expect(file_input_value).to eq("")
    end

    it "can correctly map errors" do
      Object.send(:remove_const, :TestModel)
      class TestModel < ApplicationRecord
        has_one_attached :file
      end
      
      class ExamplePage < Matestack::Ui::Page
        def response
          m_form form_config do
            form_input key: :title, type: :text, placeholder: "title", id: "title-input"
            br
            form_input key: :file, type: :file, id: "file-1-input"
            br
            form_input key: :files, type: :file, multiple: true, id: "files-input"
            br
            button 'Submit me!'
          end
        end

        def form_config
          return {
            for: :my_form,
            method: :post,
            multipart: true,
            path: form_input_file_upload_failure_form_test_path,
            failure: {
              emit: "upload_failed"
            }
          }
        end
      end

      visit '/example'
      attach_file('file-1-input', "#{File.dirname(__FILE__)}/test_files/matestack-logo.png")
      attach_file("files-input", ["#{File.dirname(__FILE__)}/test_files/matestack-logo.png", "#{File.dirname(__FILE__)}/test_files/corgi.mp4"])
      expect(page).not_to have_content("file seems to be invalid")
      expect(page).not_to have_content("files seem to be invalid")

      click_button "Submit me!"
      expect(page).to have_content("file seems to be invalid")
      expect(page).to have_content("files seem to be invalid")
    end

    it "gets properly resetted when form is successfully submitted" do
      class ExamplePage < Matestack::Ui::Page
        def response
          m_form form_config do
            form_input key: :title, type: :text, placeholder: "title", id: "title-input"
            br
            form_input key: :file_1, type: :file, id: "file-1-input"
            br
            form_input key: :files, type: :file, multiple: true, id: "files-input"
            br
            button 'Submit me!'
          end
          toggle show_on: "uploaded_successfully", hide_on: "form_submitted", id: 'async-form' do
            plain "{{event.data.file_1.instance}}"
            plain "{{event.data.file_1.name}}"
            plain "{{event.data.files}}"
          end
        end

        def form_config
          return {
            for: :my_form,
            method: :post,
            multipart: true,
            path: form_input_file_upload_success_form_test_path,
            emit: "form_submitted",
            success: {
              emit: "uploaded_successfully"
            }
          }
        end
      end

      visit '/example'
      fill_in "title-input", with: "bar"
      attach_file('file-1-input', "#{File.dirname(__FILE__)}/test_files/matestack-logo.png")
      attach_file("files-input", ["#{File.dirname(__FILE__)}/test_files/matestack-logo.png", "#{File.dirname(__FILE__)}/test_files/corgi.mp4"])
      click_button "Submit me!"
      expect(page).to have_content("file_1 instance: #<ActionDispatch::Http::UploadedFile")
      expect(page).to have_content("file_1 with name: matestack-logo.png")
      expect(page).to have_content("files[0] instance: #<ActionDispatch::Http::UploadedFile")
      expect(page).to have_content("files[1] instance: #<ActionDispatch::Http::UploadedFile")
      expect(page).to have_content("files[0] with name: matestack-logo.png")
      expect(page).to have_content("files[1] with name: corgi.mp4")

      fill_in "title-input", with: "bar"
      click_button "Submit me!"
      expect(page).to have_content("file_1 instance: nil")
      expect(page).to have_content("file_1 with name: nil")
      expect(page).to have_content("files[0] instance: nil")
      expect(page).to have_content("files[1] instance: nil")
      expect(page).to have_content("files[0] with name: nil")
      expect(page).to have_content("files[1] with name: nil")
    end
  end

    # it 'should handle multiple values correctly with multipart: true set' do
    #   matestack_render do
    #     form_config = {
    #       for: :test,
    #       method: :get,
    #       path: matestack_components_test_path
    #     }
    #     form form_config do
    #       form_checkbox key: :checkbox, label: 'Checkbox', options: [1, 2, 3, 4]
    #       form_input key: :title, label: 'Title'
  #         button 'Submit'
    #     end
    #     async rerender_on: 'update', id: 'async' do
    #       plain params[:test][:checkbox]
    #     end
    #   end
    # end

end
