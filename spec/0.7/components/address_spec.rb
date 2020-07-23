require_relative '../../support/utils'
include Utils

 describe 'Address Component', type: :feature, js: true do

   it 'Example 1 - yield a given block' do

     class ExamplePage < Matestack::Ui::Page

       def response
        components {
          address do
            plain 'Codey McCodeface'
            br
            plain '1 Developer Avenue'
            br
            plain 'Techville'
          end
        }
      end

     end

     visit '/example'

     static_output = page.html

     expected_static_output = <<~HTML
    <address>Codey McCodeface<br/>1 Developer Avenue<br/>Techville</address>
    HTML

     expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

   it 'Example 2 - render options[:text] param' do

     class ExamplePage < Matestack::Ui::Page

       def response
        components {
          address text: 'PO Box 12345'
        }
      end

     end

     visit '/example'

     static_output = page.html

     expected_static_output = <<~HTML
    <address>PO Box 12345</address>
    HTML

     expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

 end
