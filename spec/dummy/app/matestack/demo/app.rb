class Demo::App < Matestack::Ui::App

  def response
    components {
      partial :header_section
      partial :navigation_section
      partial :content_section
    }
  end

  def header_section
    partial {
      heading size: 1, text: "My App"
    }
  end

  def navigation_section
    partial {
      nav do
        transition path: :my_first_page_path do
          button text: "Page 1"
        end
        # transition path: :my_second_page_path do
        #   button text: "Page 2"
        # end
        # transition path: :my_third_page_path do
        #   button text: "Page 3"
        # end
        # transition path: :my_fourth_page_path do
        #   button text: "Page 4"
        # end
        # transition path: :my_fifth_page_path do
        #   button text: "Page 5"
        # end
        # transition path: :my_sixth_page_path do
        #   button text: "Page 6"
        # end
        # transition path: :collection_path do
        #   button text: "Collection"
        # end
        # transition path: :inline_edit_path do
        #   button text: "Inline Edit"
        # end
      end
    }
  end

  def content_section
    partial {
      div do
        page_content
      end
    }
  end


end
