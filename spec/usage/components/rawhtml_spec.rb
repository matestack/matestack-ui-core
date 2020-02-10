describe "Raw Html Component", type: :feature, js: true do

  it "allows the insertion of pure HTML: Example 1" do

    class ExamplePage < Matestack::Ui::Page
      def response
        components {
          rawhtml <<~HTML
          <h1>Hello World</h1>
          <script>alert('Really Hello!')</script>
          HTML
        }
      end
    end

    accept_alert do
      visit "/example"
    end

    static_output = page.html

    expect(static_output).to include("<h1>Hello World</h1>")
  end

end
