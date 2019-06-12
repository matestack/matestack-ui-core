require_relative '../../support/utils'
include Utils

describe 'Table Components table, th, tr, td', type: :feature, js: true do

  it 'Example 1' do

    class ExamplePage < Page::Cell::Page

      def response
        components {
          table class: 'foo' do
            tr class: 'bar' do
              th text: 'First'
              th text: 'Matestack'
              th text: 'Table'
            end
            tr do
              td text: 'One'
              td text: 'Two'
              td text: 'Three'
            end
            tr do
              td text: 'Uno'
              td text: 'Dos'
              td text: 'Tres'
            end
          end
        }
      end

    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
    <table class="foo">
      <tbody>
        <tr class="bar">
          <th>First</th>
          <th>Matestack</th>
          <th>Table</th>
        </tr>
        <tr>
          <td>One</td>
          <td>Two</td>
          <td>Three</td>
        </tr>
        <tr>
          <td>Uno</td>
          <td>Dos</td>
          <td>Tres</td>
        </tr>
      </tbody>
    </table>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'Example 2' do

    class ExamplePage < Page::Cell::Page

      def prepare
        @users = ['Jonas', 'Pascal', 'Chris']
        @numbers = ['One', 'Two', 'Three']
        @numeros = ['Uno', 'Dos', 'Tres']
      end

      def response
        components {
          table id: 'my-table-component', class: 'foo' do
            tr id: 'my-first-table-row', class: 'bar' do
              @users.each do |user|
                th class: 'user-cell', text: user
              end
            end
            tr do
              @numbers.each do |number|
                td text: number
              end
            end
            tr do
              @numeros.each do |numero|
                td text: numero
              end
            end
            tr do
              td do
                plain 'Do'
              end
              td text: 'Custom'
              td do
                plain 'Stuff'
              end
            end
          end
        }
      end

    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
    <table id="my-table-component" class="foo">
      <tbody>
        <tr id="my-first-table-row" class="bar">
          <th class="user-cell">Jonas</th>
          <th class="user-cell">Pascal</th>
          <th class="user-cell">Chris</th>
        </tr>
        <tr>
          <td>One</td>
          <td>Two</td>
          <td>Three</td>
        </tr>
        <tr>
          <td>Uno</td>
          <td>Dos</td>
          <td>Tres</td>
        </tr>
        <tr>
          <td>Do</td>
          <td>Custom</td>
          <td>Stuff</td>
        </tr>
      </tbody>
    </table>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
