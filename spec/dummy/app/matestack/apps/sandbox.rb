class Apps::Sandbox < Matestack::Ui::App

  def response
    components {
      partial :header_section
      # partial :navigation_section
      partial :content_section
    }
  end

  def header_section
    partial {
      heading size: 1, text: "Sandbox"
    }
  end

  def navigation_section
    partial {
      nav do
        transition path: :sandbox_hello_path do
          button text: "Page 1"
        end
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
