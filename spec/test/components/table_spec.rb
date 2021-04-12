require_relative '../support/utils'
include Utils

describe 'Table Components table, th, tr, td, thead, tbody, tfoot', type: :feature, js: true do

  it 'Example 1' do

    class ExamplePage < Matestack::Ui::Page
      def response
        table class: 'foo' do
          thead class: 'head' do
            tr class: 'bar' do
              th 'First'
              th 'Matestack'
              th 'Table'
            end
          end
          tbody class: 'body' do
            tr do
              td 'One'
              td 'Two'
              td 'Three'
            end
            tr do
              td 'Uno'
              td 'Dos'
              td 'Tres'
            end
          end
          tfoot class: 'foot' do
            tr do
              td 'Eins'
              td 'Zwei'
              td 'Drei'
            end
          end
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <table class="foo">
        <thead class="head">
          <tr class="bar">
            <th>First</th>
            <th>Matestack</th>
            <th>Table</th>
          </tr>
        </thead>
        <tbody class="body">
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
        <tfoot class="foot">
          <tr>
            <td>Eins</td>
            <td>Zwei</td>
            <td>Drei</td>
          </tr>
        </tfoot>
      </table>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'Example 2, when thead, tbody, tfoot are omitted, then tbody is implied' do

    class ExamplePage < Matestack::Ui::Page
      def users
        @users = ['Jonas', 'Pascal', 'Chris']
      end

      def numbers
        @numbers = ['One', 'Two', 'Three']
      end

      def numeros
        @numeros = ['Uno', 'Dos', 'Tres']
      end

      def response
        table id: 'my-table-component', class: 'foo' do
          tr id: 'my-first-table-row', class: 'bar' do
            users.each do |user|
              th user, class: 'user-cell'
            end
          end
          tr do
            numbers.each do |number|
              td number
            end
          end
          tr do
            numeros.each do |numero|
              td numero
            end
          end
          tr do
            td do
              plain 'Do'
            end
            td 'Custom'
            td do
              plain 'Stuff'
            end
          end
        end
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

  it 'Example 2, with only thead, then tbody is implied for other rows' do

    class ExamplePage < Matestack::Ui::Page

      def response
        table do
          thead do
            tr do
              th 'First'
              th 'Matestack'
              th 'Table'
            end
          end
          tr do
            td 'One'
            td 'Two'
            td 'Three'
          end
        end
      end

    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <table>
        <thead>
          <tr>
            <th>First</th>
            <th>Matestack</th>
            <th>Table</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>One</td>
            <td>Two</td>
            <td>Three</td>
          </tr>
        </tbody>
      </table>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
