require 'rails_core_spec_helper'

describe 'Default Tags Rendering', type: :feature do
  include CoreSpecUtils

  describe 'Plain Text Rendering' do

    it "plain text" do
      class ExamplePage < Matestack::Ui::Page
        def response
          plain "Hello World!"
        end
      end
      visit "/example"
      expect(page).to have_selector("body", text: "Hello World!")
    end

    it "doesn't allow script injection" do
      class ExamplePage < Matestack::Ui::Page
        def response
          plain XSS::EVIL_SCRIPT
        end
      end
      visit "/example"
      expect(page.html).to include(XSS::ESCAPED_EVIL_SCRIPT)
    end

    it "allows injection when you say #html_safe" do
      class ExamplePage < Matestack::Ui::Page
        def response
          plain XSS::EVIL_SCRIPT.html_safe
        end
      end

      # gotta accept our injected alert
      accept_alert do
        visit "/example"
      end
      # the script tag seems removed afterwards so we can't check against it here
    end

  end

  describe "Unescaped Rendering" do

    it "`unescape` allows the insertion of pure HTML" do
      class ExamplePage < Matestack::Ui::Page
        def response
          unescape <<~HTML
            <h1>Hello World</h1>
            <script>alert('Really Hello!')</script>
          HTML
        end
      end
      accept_alert do
        visit "/example"
      end
      expect(page).to have_selector("h1", text: "Hello World")
    end

  end

  describe 'Simple void Tags not supporting child Tags' do

    tags = [:area, :base, :basefont, :br, :hr, :iframe, :img, :input, :link, :meta,
      :param, :command, :keygen, :source, :embed]

    tags.each do |tag|
      it "<#{tag.to_s}>" do
        class ExamplePage < Matestack::Ui::Page
          def response
            self.send(params[:tag].to_s, foo: 'foo-value', "bar-attr": 'bar-value', data: { baz: "baz-value" })
          end
        end
        visit "/example?tag=#{tag.to_s}"
        expect(page).to have_selector("#{tag.to_s}[foo='foo-value'][bar-attr='bar-value'][data-baz='baz-value']", visible: :all)
      end
    end

  end

  describe 'Simple Tags supporing child Tags, plain text or no child at all' do

    tags = [:a, :abbr, :acronym, :address, :applet, :article, :aside, :audio, :b,
      :bdi, :bdo, :big, :blockquote, :body, :button, :canvas, :center, :cite, :code, :data,
      :datalist, :dd, :del, :details, :dfn, :dialog,
      :dir, :div, :dl, :dt, :em, :fieldset, :figcaption, :figure, :font, :footer, :form,
      :h1, :h2, :h3, :h4, :h5, :h6, :header, :html, :i, :ins, :kbd, :label, :legend, :li, :main, :map,
      :mark, :meter, :nav, :object, :ol, :optgroup, :option, :output, :picture, :pre,
      :progress, :q, :rp, :rt, :ruby, :s, :samp, :section, :small, :span, :strike, :strong,
      :sub, :summary, :sup, :time, :tt, :u, :ul, :var, :video]


    tags.each do |tag|
      it "<#{tag.to_s}>" do
        # no inner html at all
        class ExamplePage < Matestack::Ui::Page
          def response
            self.send(params[:tag].to_s, foo: 'foo-value', "bar-attr": 'bar-value', data: { baz: "baz-value" })
          end
        end
        visit "/example?tag=#{tag.to_s}"
        expect(page).not_to have_selector("#{tag.to_s}[foo='foo-value'][bar-attr='bar-value'][data-baz='baz-value'][text='']", text: "", visible: :all)
        expect(page).to have_selector("#{tag.to_s}[foo='foo-value'][bar-attr='bar-value'][data-baz='baz-value']", text: "", visible: :all)

        # inner html as plain text via first non-hash argument
        class ExamplePage < Matestack::Ui::Page
          def response
            self.send(params[:tag].to_s, "plain text content", foo: 'foo-value', "bar-attr": 'bar-value', data: { baz: "baz-value" })
          end
        end
        visit "/example?tag=#{tag.to_s}"
        expect(page).not_to have_selector("#{tag.to_s}[foo='foo-value'][bar-attr='bar-value'][data-baz='baz-value'][text='plain text content']", text: "plain text content", visible: :all)
        expect(page).to have_selector("#{tag.to_s}[foo='foo-value'][bar-attr='bar-value'][data-baz='baz-value']", text: "plain text content", visible: :all)

        # inner html as plain text via text key in hash argument
        class ExamplePage < Matestack::Ui::Page
          def response
            self.send(params[:tag].to_s, foo: 'foo-value', "bar-attr": 'bar-value', data: { baz: "baz-value" }, text: "plain text content")
          end
        end
        visit "/example?tag=#{tag.to_s}"
        expect(page).not_to have_selector("#{tag.to_s}[foo='foo-value'][bar-attr='bar-value'][data-baz='baz-value'][text='plain text content']", text: "plain text content", visible: :all)
        expect(page).to have_selector("#{tag.to_s}[foo='foo-value'][bar-attr='bar-value'][data-baz='baz-value']", text: "plain text content", visible: :all)

        # inner html via block
        class ExamplePage < Matestack::Ui::Page
          def response
            self.send(params[:tag].to_s, foo: 'foo-value', "bar-attr": 'bar-value', data: { baz: "baz-value" }) do
              # using span as an example for a child tag (can be any tag, if parent tag is supporting it)
              span do
                plain "block content"
              end
            end
          end
        end
        visit "/example?tag=#{tag.to_s}"
        expect(page).to have_selector("#{tag.to_s}[foo='foo-value'][bar-attr='bar-value'][data-baz='baz-value'] span", text: "block content", visible: :all)

        # inner html via block, text key gets ignored
        class ExamplePage < Matestack::Ui::Page
          def response
            self.send(params[:tag].to_s, foo: 'foo-value', "bar-attr": 'bar-value', data: { baz: "baz-value" }, text: "plain text content gets ignored") do
              span do
                plain "block content"
              end
            end
          end
        end
        visit "/example?tag=#{tag.to_s}"
        expect(page).to have_selector("#{tag.to_s}[foo='foo-value'][bar-attr='bar-value'][data-baz='baz-value'] span", text: "block content", visible: :all)
        expect(page).not_to have_selector("#{tag.to_s}[foo='foo-value'][bar-attr='bar-value'][data-baz='baz-value']", text: "plain text content gets ignored", visible: :all)

        # inner html via block, text via first argument gets ignored
        class ExamplePage < Matestack::Ui::Page
          def response
            self.send(params[:tag].to_s, "plain text content gets ignored", foo: 'foo-value', "bar-attr": 'bar-value', data: { baz: "baz-value" }) do
              span do
                plain "block content"
              end
            end
          end
        end
        visit "/example?tag=#{tag.to_s}"
        expect(page).to have_selector("#{tag.to_s}[foo='foo-value'][bar-attr='bar-value'][data-baz='baz-value'] span", text: "block content", visible: :all)
        expect(page).not_to have_selector("#{tag.to_s}[foo='foo-value'][bar-attr='bar-value'][data-baz='baz-value']", text: "plain text content gets ignored", visible: :all)
      end
    end

    it '<p> aliased via `paragraph`' do
      class ExamplePage < Matestack::Ui::Page
        def response
          paragraph "plain text content via first argument", foo: 'foo-value', "bar-attr": 'bar-value', data: { baz: "baz-value" }
          paragraph foo: 'foo-value', "bar-attr": 'bar-value', data: { baz: "baz-value" }, text: "plain text content"
          paragraph foo: 'foo-value', "bar-attr": 'bar-value', data: { baz: "baz-value" } do
            span do
              plain "block content"
            end
          end
        end
      end
      visit "/example"
      expect(page).not_to have_selector("p[foo='foo-value'][bar-attr='bar-value'][data-baz='baz-value'][text='plain text content via first argument']", text: "plain text content via first argument", visible: true)
      expect(page).to have_selector("p[foo='foo-value'][bar-attr='bar-value'][data-baz='baz-value']", text: "plain text content via first argument", visible: true)
      expect(page).not_to have_selector("p[foo='foo-value'][bar-attr='bar-value'][data-baz='baz-value'][text='plain text content']", text: "plain text content", visible: true)
      expect(page).to have_selector("p[foo='foo-value'][bar-attr='bar-value'][data-baz='baz-value']", text: "plain text content", visible: true)
      expect(page).to have_selector("p[foo='foo-value'][bar-attr='bar-value'][data-baz='baz-value'] span", text: "block content", visible: true)
    end

    it '<h{x}> aliased via `heading size: {x}`' do
      class ExamplePage < Matestack::Ui::Page
        def response
          (1..6).each do |i|
            heading "Heading #{i}", size: i, foo: 'foo-value', "bar-attr": 'bar-value', data: { baz: "baz-value" }
          end
          (1..6).each do |i|
            heading size: i, foo: 'foo-value', "bar-attr": 'bar-value', data: { baz: "baz-value" } do
              span do
                plain "Heading Block Content #{i}"
              end
            end
          end
        end
      end
      visit "/example"
      (1..6).each do |i|
        expect(page).not_to have_selector("h#{i}[foo='foo-value'][bar-attr='bar-value'][data-baz='baz-value'][text='Heading #{i}']", text: "Heading #{i}", visible: true)
        expect(page).to have_selector("h#{i}[foo='foo-value'][bar-attr='bar-value'][data-baz='baz-value']", text: "Heading #{i}", visible: true)

        expect(page).to have_selector("h#{i}[foo='foo-value'][bar-attr='bar-value'][data-baz='baz-value'] span", text: "Heading Block Content #{i}", visible: true)
      end
    end

  end

  describe 'Tags with processed attributes' do

    it '<a> path -> href' do
      class ExamplePage < Matestack::Ui::Page
        def response
          a "Link Text 1", path: "https://matestack.io", title: "Link 1"
          a "Link Text 2", href: "https://matestack.io", title: "Link 2"
        end
      end
      visit "/example"
      expect(page).to have_selector("a[title='Link 1'][href='https://matestack.io']", text: "Link Text 1")
      expect(page).to have_selector("a[title='Link 2'][href='https://matestack.io']", text: "Link Text 2")
    end

    it '<img> path -> src via Asset Pipeline' do
      class ExamplePage < Matestack::Ui::Page
        def response
          img src: "#{ActionController::Base.helpers.asset_path('matestack-logo.png')}", width: 500, height: 300, alt: "logo_1"
          img path: "matestack-logo.png", width: 500, height: 300, alt: "logo_2"
        end
      end
      visit "/example"
      expect(page).to have_selector(
        "img[alt='logo_1'][height='300'][width='500'][src='#{ActionController::Base.helpers.asset_path('matestack-logo.png')}']"
      )
      expect(page).to have_selector(
        "img[alt='logo_2'][height='300'][width='500'][src='#{ActionController::Base.helpers.asset_path('matestack-logo.png')}']"
      )
    end

  end

  describe 'Context dependent Tags' do

    describe 'Table Tags' do

      it '<table> and children' do
        class ExamplePage < Matestack::Ui::Page
          def response
            table class: 'foo' do
              caption do
                plain "Test Table"
              end
              colgroup do
                col span:"2", style:"background-color:red"
                col style:"background-color:yellow"
              end
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
        visit "/example"

        expect(page).to have_selector("table[class='foo'] > caption", text: "Test Table", visible: true)

        expect(page).to have_selector("table[class='foo'] > colgroup > col[span='2'][style='background-color:red']", text: "", visible: :all)
        expect(page).to have_selector("table[class='foo'] > colgroup > col[style='background-color:yellow']", text: "", visible: :all)

        expect(page).to have_selector("table[class='foo'] > thead[class='head'] > tr[class='bar'] th", text: "First", visible: true)
        expect(page).to have_selector("table[class='foo'] > thead[class='head'] > tr[class='bar'] th", text: "Matestack", visible: true)
        expect(page).to have_selector("table[class='foo'] > thead[class='head'] > tr[class='bar'] th", text: "Table", visible: true)

        expect(page).to have_selector("table[class='foo'] > tbody[class='body'] > tr > td", text: "One", visible: true)
        expect(page).to have_selector("table[class='foo'] > tbody[class='body'] > tr > td", text: "Two", visible: true)
        expect(page).to have_selector("table[class='foo'] > tbody[class='body'] > tr > td", text: "Three", visible: true)
        expect(page).to have_selector("table[class='foo'] > tbody[class='body'] > tr > td", text: "Uno", visible: true)
        expect(page).to have_selector("table[class='foo'] > tbody[class='body'] > tr > td", text: "Dos", visible: true)
        expect(page).to have_selector("table[class='foo'] > tbody[class='body'] > tr > td", text: "Tres", visible: true)

        expect(page).to have_selector("table[class='foo'] > tfoot[class='foot'] > tr > td", text: "Eins", visible: true)
        expect(page).to have_selector("table[class='foo'] > tfoot[class='foot'] > tr > td", text: "Zwei", visible: true)
        expect(page).to have_selector("table[class='foo'] > tfoot[class='foot'] > tr > td", text: "Drei", visible: true)
      end
    end

    it '<svg> and Children' do
      class ExamplePage < Matestack::Ui::Page
        def response
          svg width: "100", height: "100" do
            # svg child tags currently not supported, using documented custom tag rendering approach
            plain tag(:circle, cx: "50", cy: "50", r: "40", stroke: "green", "stroke-width": "4", fill: "yellow")
          end
        end
      end
      visit "/example"
      expect(page).to have_selector("svg[width='100'][height='100'] circle[cx='50'][cy='50'][r='40'][stroke='green'][stroke-width='4'][fill='yellow']", text: "", visible: true)
    end

    it '<select> with <options>' do
      class ExamplePage < Matestack::Ui::Page
        def response
          select do
            option "One", value: 1
            option "Two", value: 2
          end
        end
      end
      visit "/example"
      expect(page).to have_selector("select option[value='1']", text: "One", visible: true)
      expect(page).to have_selector("select option[value='2']", text: "Two", visible: true)
    end

    it '<track> in <audio> or <video>' do
      class ExamplePage < Matestack::Ui::Page
        def response
          video width: "320", height: "240", controls: true do
            track src: "fgsubtitles_en.vtt", kind: "subtitles", srclang: "en", label: "English"
          end
        end
      end
      visit "/example"
      expect(page).to have_selector("video[width='320'][height='240'][controls] track[src='fgsubtitles_en.vtt']", text: "", visible: :all)
    end

  end

  describe 'Head only Tags' do

    it '<head>' do
      class ExamplePage < Matestack::Ui::Page
        def response
          head do

          end
        end
      end
      visit "/example?only_page=true"
      expect(page).to have_selector("head", text: "", visible: :all)
    end

    it '<style>' do
      class ExamplePage < Matestack::Ui::Page
        def response
          style type: "text/css" do
            plain "h1 {color:red;}"
          end
        end
      end
      visit "/example?only_page=true"
      expect(page).to have_selector("style[type='text/css']", text: "h1 {color:red;}", visible: false)
    end

    it '<title>' do
      class ExamplePage < Matestack::Ui::Page
        def response
          title do
            plain "My App"
          end
        end
      end
      visit "/example?only_page=true"
      expect(page).to have_selector("title", text: "My App", visible: false)
    end

  end

  describe 'Tags supporting only Text as Child' do

    it '<noscript>' do
      class ExamplePage < Matestack::Ui::Page
        def response
          noscript do
            plain "no script"
          end
        end
      end
      visit "/example"
      expect(page).to have_selector("noscript", text: "no script", visible: false)
    end

    it '<wbr>' do
      class ExamplePage < Matestack::Ui::Page
        def response
          paragraph do
            plain "some"
            wbr
            plain "text"
          end
        end
      end
      visit "/example"
      expect(page).to have_selector("p", text: "some text", visible: true)
      expect(page).to have_selector("p wbr", visible: false)
    end

    it '<textarea>' do
      class ExamplePage < Matestack::Ui::Page
        def response
          textarea rows:"4", cols: "50" do
            plain "some placeholder text"
          end
        end
      end
      visit "/example"
      expect(page).to have_selector("textarea[rows='4'][cols='50']", text: "some placeholder text", visible: true)
    end

  end

  describe 'invisible tags' do

    it '<script>' do
      # don't know how to expect the script tag -> it's removed by the headless browser and content not rendered
      #
      # class ExamplePage < Matestack::Ui::Page
      #   def response
      #     script do
      #       plain "some script"
      #     end
      #   end
      # end
      # visit "/example"
      # expect(page).to have_selector("script", text: "some script", visible: false)
    end

    it '<template>' do
      # template tag is removed by browser, content will be visible
      class ExamplePage < Matestack::Ui::Page
        def response
          div class: "template-wrapper" do
            template do
              plain "some placeholder text" # will be converted to a fragment by the browser
            end
          end
        end
      end
      visit "/example"
      expect(page).to have_selector("div[class='template-wrapper'] > template", visible: :all)
    end

  end

end
