describe Matestack::Ui::Core::Render do
  describe "#default_render" do

    describe "implicit rendering for index actions", type: :feature, js: true do
      before do
        module Clients
        end

        class Clients::BookingsController < ApplicationController
          include Matestack::Ui::Core::ApplicationHelper

          def index
          end
        end

        Rails.application.routes.draw do
          namespace :clients do
            resources :bookings
          end
        end

        class Apps::Clients < Matestack::Ui::App
          def response
            components {
              page_content
            }
          end
        end

        module Pages::Clients
        end

        class Pages::Clients::Bookings < Matestack::Ui::Page
          def response
            components {
              plain "Hello from the Pages::Clients::Bookings page."
            }
          end
        end
      end
      after do
        Rails.application.reload_routes!
      end
      specify do
        visit "/clients/bookings"
        expect(page).to have_text "Hello from the Pages::Clients::Bookings page."
      end
    end

    describe "implicit rendering for show actions", type: :feature, js: true do
      before do
        module Clients
        end

        class Clients::BookingsController < ApplicationController
          include Matestack::Ui::Core::ApplicationHelper

          def show
            @id = params[:id]
          end
        end

        Rails.application.routes.draw do
          namespace :clients do
            resources :bookings
          end
        end

        class Apps::Clients < Matestack::Ui::App
          def response
            components {
              page_content
            }
          end
        end

        module Pages::Clients
        end

        class Pages::Clients::Booking < Matestack::Ui::Page  # singular name `Booking`!
          def response
            components {
              plain "Hello from the Pages::Clients::Booking page with id #{@id}."
            }
          end
        end
      end
      after do
        Rails.application.reload_routes!
      end
      specify do
        visit "/clients/bookings/123"
        expect(page).to have_text "Hello from the Pages::Clients::Booking page with id 123."
      end
    end

    describe "implicit rendering for custom actions", type: :feature, js: true do
      before do
        module Clients
        end

        class Clients::BookingsController < ApplicationController
          include Matestack::Ui::Core::ApplicationHelper

          def step1
          end
        end

        Rails.application.routes.draw do
          namespace :clients do
            get 'bookings/step1', to: 'bookings#step1'
          end
        end

        class Apps::Clients < Matestack::Ui::App
          def response
            components {
              page_content
            }
          end
        end

        module Pages::Clients
        end

        class Pages::Clients::Bookings::Step1 < Matestack::Ui::Page
          def response
            components {
              plain "Hello from the Pages::Clients::Bookings::Step1 page."
            }
          end
        end
      end
      after do
        Rails.application.reload_routes!
      end
      specify do
        visit "/clients/bookings/step1"
        expect(page).to have_text "Hello from the Pages::Clients::Bookings::Step1 page."
      end
    end

  end
end