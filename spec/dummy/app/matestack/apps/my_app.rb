class Apps::MyApp < Matestack::Ui::App

  def response
    components {
      header do
        heading size: 1, text: "My App"
      end
      nav do
        transition path: :my_first_page_path do
          button text: "Page 1"
        end
        transition path: :my_second_page_path do
          button text: "Page 2"
        end
        transition path: :my_third_page_path do
          button text: "Page 3"
        end
        transition path: :my_fourth_page_path do
          button text: "Page 4"
        end
        transition path: :my_fifth_page_path do
          button text: "Page 5"
        end
        transition path: :my_sixth_page_path do
          button text: "Page 6"
        end
      end
      main do
        page_content
      end
    }
  end

end
