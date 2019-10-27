require_relative '../../support/utils'
include Utils

describe 'Label Component', type: :feature, js: true do

  it 'Example 1' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          # simple label
          label text: 'I am simple'

          # enhanced label
          label id: 'my-id', for: 'label for something', class: 'my-class' do
            plain 'I am enhanced'
          end

          # with form attribute
          label id: 'form_label', for: "form", form: 'form1', text: 'Label for Form1'
        }
      end

    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
    <label>I am simple</label>
    <label for="label for something" id="my-id" class="my-class">I am enhanced</label>

    <label for="form" form="form1" id="form_label" >Label for Form 1</label>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
