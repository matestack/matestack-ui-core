describe "static component", type: :feature, js: true do

  @components = Support::Components.specs

  def visit_page component
    visit "/components_tests/static_rendering_test/#{component}"
  end

  def visit_page_with_app component
    visit "/components_tests_with_app/static_rendering_test/#{component}"
  end

  def within_main_page_div &block
    within("#pages_components_tests_static_rendering_test") do
      yield
    end
  end

  @components.each do |component_key, component|

    component[:options][:optional].each do |optional_option, option_type|

      it "#{component_key} can take #{optional_option}" do
        visit_page component_key
        within_main_page_div do
          case option_type
          when :string
            expect(page.has_xpath?("//#{component[:tag]}[@#{optional_option}='attr_value']")).to be true
          when :hash
            expect(page.has_xpath?("//#{component[:tag]}[@key1='value1']")).to be true
            expect(page.has_xpath?("//#{component[:tag]}[@key2='value2']")).to be true
          when :boolean
            expect(page.has_xpath?("//#{component[:tag]}[@#{optional_option}='true']")).to be true
          end
        end
      end

      it "#{component_key} can take #{optional_option}" do
        visit_page_with_app component_key
        within_main_page_div do
          case option_type
          when :string
            expect(page.has_xpath?("//#{component[:tag]}[@#{optional_option}='attr_value']")).to be true
          when :hash
            expect(page.has_xpath?("//#{component[:tag]}[@key1='value1']")).to be true
            expect(page.has_xpath?("//#{component[:tag]}[@key2='value2']")).to be true
          when :boolean
            expect(page.has_xpath?("//#{component[:tag]}[@#{optional_option}='true']")).to be true
          end
        end
      end

    end
    #
    # it "#{component_key} can be rendered without any options but with content" do
    #   visit_page component_key
    #   within_main_page_div do
    #     rendered_component = all(component[:tag])[1]
    #     expect(rendered_component[:id]).to eq("")
    #     expect(rendered_component[:class]).to eq("")
    #     expect(rendered_component.text).to eq("content")
    #   end
    # end
    #
    # it "#{component_key} can be rendered with class and id option and content" do
    #   visit_page component_key
    #   within_main_page_div do
    #     rendered_component = all(component[:tag])[2]
    #     expect(rendered_component[:id]).to eq("my-id")
    #     expect(rendered_component[:class]).to eq("my-class")
    #     expect(rendered_component.text).to eq("content")
    #   end
    # end

  end


end
