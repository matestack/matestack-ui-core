require_relative '../../support/utils'
include Utils

describe 'List Components ul, ol, li', type: :feature, js: true do

  it 'Unordered lists' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # simple unordered list
        ul do
          5.times do
            li text: 'I am simple!'
          end
        end
        # advanced unordered list
        ul id: 'custom-unordered-list', class: 'custom-list' do
          li class: 'inline-li-element', text: 'I am inline text'
          li class: 'yield-li-element' do
            plain 'I am yielded plain'
          end
          li class: 'inline-li-element', text: 'I am inline text'
        end
      end
    end

    visit "/example"
    static_output = page.html
    expected_static_output = <<~HTML
      <ul>
        <li>I am simple!</li>
        <li>I am simple!</li>
        <li>I am simple!</li>
        <li>I am simple!</li>
        <li>I am simple!</li>
      </ul>
      <ul id="custom-unordered-list" class="custom-list">
        <li class="inline-li-element">I am inline text</li>
        <li class="yield-li-element">I am yielded plain</li>
        <li class="inline-li-element">I am inline text</li>
      </ul>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'Ordered list' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # simple ordered list
        ol do
          5.times do
            li text: 'I am simple!'
          end
        end
        # advanced ordered list
        ol id: 'custom-ordered-list', class: 'custom-list' do
          li class: 'inline-li-element', text: 'I am inline text'
          li class: 'yield-li-element' do
            plain 'I am yielded plain'
          end
          li class: 'inline-li-element', text: 'I am inline text'
        end
      end
    end

    visit "/example"
    static_output = page.html
    expected_static_output = <<~HTML
      <ol>
        <li>I am simple!</li>
        <li>I am simple!</li>
        <li>I am simple!</li>
        <li>I am simple!</li>
        <li>I am simple!</li>
      </ol>
      <ol id="custom-ordered-list" class="custom-list">
        <li class="inline-li-element">I am inline text</li>
        <li class="yield-li-element">I am yielded plain</li>
        <li class="inline-li-element">I am inline text</li>
      </ol>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'Nested lists' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # lists within lists
        ul id: 'favorite-dishes-list' do
          ul do
            3.times do
              li text: 'Pizza over all'
            end
          end
          ol id: 'favorite-breakfast' do
            li class: 'inline-li-element', text: 'Coffee'
            li class: 'yield-li-element' do
              plain 'Muesli'
            end
            li class: 'inline-li-element', text: 'Orange juice'
          end
          li class: 'italian-food', text: 'Pasta is okay, too'
          li class: 'yield-american-dish' do
            plain 'Maybe sometimes burgers'
          end
          li class: 'italian-food', text: 'Lasagna for life'
        end
      end
    end

    visit "/example"
    static_output = page.html
    expected_static_output = <<~HTML
      <ul id="favorite-dishes-list">
        <ul>
          <li>Pizza over all</li>
          <li>Pizza over all</li>
          <li>Pizza over all</li>
        </ul>
        <ol id="favorite-breakfast">
          <li class="inline-li-element">Coffee</li>
          <li class="yield-li-element">Muesli</li>
          <li class="inline-li-element">Orange juice</li>
        </ol>
        <li class="italian-food">Pasta is okay, too</li>
        <li class="yield-american-dish">Maybe sometimes burgers</li>
        <li class="italian-food">Lasagna for life</li>
      </ul>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
