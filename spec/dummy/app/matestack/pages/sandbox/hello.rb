class Pages::Sandbox::Hello < Matestack::Ui::Page

  def response
    components {
      div id: "some-id", class: "some-class" do
        plain "hello you! go ahead and modify me!"
        br
        br
        plain "you can find me in 'spec/dummy/matestack/pages/sandbox/hello.rb'"
      end
    }
  end

end
