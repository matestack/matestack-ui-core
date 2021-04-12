require_relative "../../../support/utils"
include Utils

describe "Async Component", type: :feature, js: true do

  describe "defer" do

    it "deferred loading without any timeout, deferred request right after component mounting" do
      class SomeComponent < Matestack::Ui::Component
        def response
          async defer: true, id: 'async-some-component' do
            div id: "my-deferred-div-on-component" do
              plain "#{@options[:current_time]}"
            end
          end
        end

        register_self_as(:some_component)
      end


      class ExamplePage < Matestack::Ui::Page
        def response
          @current_time = DateTime.now.strftime('%Q')
          div id: "my-reference-div" do
            plain "#{@current_time}"
          end
          async id: 'async-example-page' do
            div id: "my-not-deferred-div" do
              plain "#{@current_time}"
            end
          end
          async defer: true, id: 'async-example-page-defer' do
            div id: "my-deferred-div" do
              plain "#{@current_time}"
            end
          end
          some_component current_time: @current_time
        end
      end

      visit "/example"
      sleep 0.5
      initial_timestamp = page.find("#my-reference-div").text #initial page load
      non_deferred_timestamp = page.find("#my-not-deferred-div").text #initial page load
      deferred_timestamp = page.find("#my-deferred-div").text #deferred loading
      deferred_timestamp_on_component = page.find("#my-deferred-div-on-component").text #deferred loading
      expect(non_deferred_timestamp).to eq initial_timestamp
      expect(deferred_timestamp).to be > initial_timestamp
      expect(deferred_timestamp_on_component).to be > initial_timestamp
      expect(deferred_timestamp.to_i - initial_timestamp.to_i).to be_between(0, 2000).inclusive
      expect(deferred_timestamp_on_component.to_i - initial_timestamp.to_i).to be_between(0, 2000).inclusive
    end

    it "deferred loading with a specific timeout" do
      class ExamplePage < Matestack::Ui::Page
        def response
          @current_time = DateTime.now.strftime('%Q')
          div id: "my-reference-div" do
            plain "#{@current_time}"
          end
          async id: 'async-example-page' do
            div id: "my-not-deferred-div" do
              plain "#{@current_time}"
            end
          end
          async defer: 1000, id: 'async-example-page-defer' do
            div id: "my-deferred-div" do
              plain "#{@current_time}"
            end
          end
        end
      end

      visit "/example"
      initial_timestamp = page.find("#my-reference-div").text #initial page load
      non_deferred_timestamp = page.find("#my-not-deferred-div").text #initial page load
      deferred_timestamp = page.find("#my-deferred-div").text #deferred loading
      expect(non_deferred_timestamp).to eq initial_timestamp
      expect(deferred_timestamp).to be > initial_timestamp
      expect(deferred_timestamp.to_i - initial_timestamp.to_i).to be_between(1000, 3000).inclusive
    end

    it "multiple deferred loadings with a specific timeout" do

      class ExamplePage < Matestack::Ui::Page
        def response
          @current_time = DateTime.now.strftime('%Q')
          div id: "my-reference-div" do
            plain "#{@current_time}"
          end
          async id: 'async-example-page' do
            div id: "my-not-deferred-div" do
              plain "#{@current_time}"
            end
          end
          async defer: 1000, id: 'async-example-page-defer' do
            div id: "my-deferred-div" do
              plain "#{@current_time}"
            end
          end
          async defer: 2000, id: 'async-example-page-defer-slow' do
            div id: "my-second-deferred-div" do
              plain "#{@current_time}"
            end
          end
        end
      end

      visit "/example"
      initial_timestamp = page.find("#my-reference-div").text #initial page load
      non_deferred_timestamp = page.find("#my-not-deferred-div").text #initial page load
      deferred_timestamp = page.find("#my-deferred-div").text #deferred loading
      second_deferred_timestamp = page.find("#my-second-deferred-div").text #deferred loading
      expect(non_deferred_timestamp).to eq initial_timestamp
      expect(deferred_timestamp).to be > initial_timestamp
      expect(second_deferred_timestamp).to be > initial_timestamp
      expect(deferred_timestamp.to_i - initial_timestamp.to_i).to be_between(1000, 3000).inclusive
      expect(second_deferred_timestamp.to_i - initial_timestamp.to_i).to be_between(2000, 4000).inclusive
    end

    it "deferred loading without any timeout, triggered by on_show event" do
      class ExamplePage < Matestack::Ui::Page
        def response
          @current_time = DateTime.now.strftime('%Q')
          div id: "my-reference-div" do
            plain "#{@current_time}"
          end
          async defer: true, show_on: "my_event", hide_on: "my_other_event", id: 'async-example-page-hide-show' do
            plain "waited for 'my_event'"
            div id: "my-deferred-div" do
              plain "#{@current_time}"
            end
          end
        end
      end

      visit "/example"
      initial_timestamp = page.find("#my-reference-div").text #initial page load
      expect(page).not_to have_content("waited for 'my_event'")
      
      sleep 2
      page.execute_script('MatestackUiCore.eventHub.$emit("my_event")')
      expect(page).to have_content("waited for 'my_event'")
      deferred_timestamp = page.find("#my-deferred-div").text #deferred loading after click
      expect(deferred_timestamp.to_i - initial_timestamp.to_i).to be_between(2000, 4000).inclusive
      
      sleep 1
      page.execute_script('MatestackUiCore.eventHub.$emit("my_other_event")')
      page.execute_script('MatestackUiCore.eventHub.$emit("my_event")')
      expect(page).to have_content("waited for 'my_event'")
      new_deferred_timestamp = page.find("#my-deferred-div").text #deferred loading after another click
      expect(new_deferred_timestamp.to_i - deferred_timestamp.to_i).to be_between(1000, 2000).inclusive
    end

  end

end
