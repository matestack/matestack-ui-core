require_relative '../../support/utils'
include Utils

describe 'Rails View Component', type: :feature, js: true do

  after :all do
    Object.send(:remove_const, :ExampleController)
    load "#{Rails.root}/app/controllers/example_controller.rb"
  end

  it 'renders given view on to page' do
    class ExampleController < ApplicationController
      def page
        @title = 'Test Title'
        render ExamplePage
      end
    end

    class ExamplePage < Matestack::Ui::Page
      def response
        div id: 'page' do
          rails_view view: 'demo/header'
          rails_view partial: 'demo/header'
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <div id="page">
        <header>
          <h1>Rails View</h1>
          <p>Test Title</p>
        </header>
        <header>
          <h1>Rails Partial</h1>
          <p>Test Title</p>
        </header>
      </div>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
