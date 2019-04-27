class Apps::MyApp < App::Cell::App

  def response
    components {
      header do
        heading size: 1, text: "My App"
      end
      nav do
        [
          :my_first_page,
          :my_second_page,
          :my_third_page,
          :my_fourth_page,
          :my_fifth_page,
          :my_sixth_page
        ].each do |page|
          transition path: "#{page}_path".to_sym do
            button do
              plain page
            end
          end
        end
      end
      main do
        br
        page_content
      end
    }
  end

end
