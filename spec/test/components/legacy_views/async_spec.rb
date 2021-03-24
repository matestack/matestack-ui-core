require_relative "../../support/utils"
include Utils

describe "Async Component", type: :feature, js: true do

  it 'should work on rails legacy views' do
    class Components::LegacyViews::Pages::Async < Matestack::Ui::Component
      def response
        async rerender_on: 'update_time', id: 'async-legacy-integratable' do
          paragraph DateTime.now.strftime('%Q'), id: 'time'
        end
        onclick emit: 'update_time' do
          button 'Click me!'
        end
        toggle show_on: 'async_rerender_error', id: 'async-error' do
          plain 'Error - {{event.data.id}}'
        end
      end
    end

    visit 'legacy_views/async_custom_component'
    initial_content = page.find("#time").text

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("update_time")')
    expect(page).not_to have_content(initial_content)
  end

  describe 'with collection' do
    before :all do
      class Components::LegacyViews::Pages::Async < Matestack::Ui::Component
        cattr_accessor :collection
        def response
          collection.each_with_index do |item, index|
            async rerender_on: "update_item_#{index}, update_items", id: "async-legacy-integratable-#{index}" do
              paragraph "#{item} - #{DateTime.now.strftime('%Q')}"
            end
          end
          onclick emit: 'update_items' do
            button 'Click me!'
          end
          toggle show_on: 'async_rerender_error', id: 'async-error' do
            plain 'Error - {{event.data.id}}'
          end
        end
      end
      Components::LegacyViews::Pages::Async.collection = %w[aa bb cc]
    end

    it 'should rerender correctly' do
      visit 'legacy_views/async_custom_component'
      Components::LegacyViews::Pages::Async.collection.each do |item|
        expect(page).to have_content(item)
      end

      Components::LegacyViews::Pages::Async.collection[0] = 'aaa'
      page.execute_script('MatestackUiCore.matestackEventHub.$emit("update_item_0")')

      expect(page).to have_content('aaa')
      expect(page).to have_content('bb')
      expect(page).to have_content('cc')

      time = Time.now
      Components::LegacyViews::Pages::Async.collection.map! { |item| "#{item} - #{time}"}
      page.execute_script('MatestackUiCore.matestackEventHub.$emit("update_items")')
      expect(page).to have_content("aaa - #{time}")
      expect(page).to have_content("bb - #{time}")
      expect(page).to have_content("cc - #{time}")
    end

    it 'should handle errors if collection item is missing' do
      visit 'legacy_views/async_custom_component'
      Components::LegacyViews::Pages::Async.collection.each do |item|
        expect(page).to have_content(item)
      end

      Components::LegacyViews::Pages::Async.collection = %w[aa bb]
      page.execute_script('MatestackUiCore.matestackEventHub.$emit("update_items")')
      expect(page).to have_content('aa')
      expect(page).to have_content('bb')
      expect(page).to have_content('cc') # old element remains on the page
      expect(page).to have_content('Error - async-legacy-integratable-2')
    end

  end

end
