describe "static component", type: :feature, js: true do

  @components = Support::Components.specs

  def visit_page component
    visit "/components_tests/static_rendering_test/#{component}"
  end

  def visit_page_with_app component
    visit "/components_tests_with_app/static_rendering_test/#{component}"
  end

  @components.each do |component_key, component|

    component[:options][:optional].each do |optional_option, option_type|


      it "#{component_key} can take #{optional_option}" do
        visit_page component_key
        within("#pages_components_tests_static_rendering_test") do
          case option_type
          when :string
            expect(page.has_xpath?("//#{component[:tag]}[@#{optional_option}='attr_value']", visible: :all)).to be true
          when :hash
            expect(page.has_xpath?("//#{component[:tag]}[@key1='value1']", visible: :all)).to be true
            expect(page.has_xpath?("//#{component[:tag]}[@key2='value2']", visible: :all)).to be true
          when :boolean
            expect(page.has_xpath?("//#{component[:tag]}[@#{optional_option}='true']", visible: :all)).to be true
          end
        end
      end

      it "#{component_key} can take #{optional_option}" do
        visit_page_with_app component_key
        within("#pages_components_tests_with_app_static_rendering_test") do
          case option_type
          when :string
            expect(page.has_xpath?("//#{component[:tag]}[@#{optional_option}='attr_value']", visible: :all)).to be true
          when :hash
            expect(page.has_xpath?("//#{component[:tag]}[@key1='value1']", visible: :all)).to be true
            expect(page.has_xpath?("//#{component[:tag]}[@key2='value2']", visible: :all)).to be true
          when :boolean
            expect(page.has_xpath?("//#{component[:tag]}[@#{optional_option}='true']", visible: :all)).to be true
          end
        end
      end

    end

    if component[:block] == true

      it "#{component_key} can take a block of components" do
        visit_page component_key
        within("#pages_components_tests_static_rendering_test") do
          element = page.find("#with_block")
          expect(element.text).to eq("block content")
        end
      end


      it "#{component_key} can take a block of components" do
        visit_page_with_app component_key
        within("#pages_components_tests_with_app_static_rendering_test") do
          element = page.find("#with_block")
          expect(element.text).to eq("block content")
        end
      end

    end

    unless component[:optional_dynamics].nil?
      if component[:optional_dynamics][:rerender_on][:client_side_event] == true

        it "#{component_key} can rerender on client side event if set to dynamic without app" do
          visit_page component_key
          within("#pages_components_tests_static_rendering_test") do
            element = page.find("#rerender_on_client_side_event")
            before_rerendering = element.text
            page.execute_script('BasemateUiCore.basemateEventHub.$emit("rerender", "rerender_on_client_side_event")')
            element = page.find("#rerender_on_client_side_event")
            after_rerendering = element.text
            expect(before_rerendering).not_to eq(after_rerendering)
          end
        end

        it "#{component_key} can rerender on client side event if set to dynamic with app" do
          visit_page_with_app component_key
          within("#pages_components_tests_with_app_static_rendering_test") do
            element = page.find("#rerender_on_client_side_event")
            before_rerendering = element.text
            page.execute_script('BasemateUiCore.basemateEventHub.$emit("rerender", "rerender_on_client_side_event")')
            element = page.find("#rerender_on_client_side_event")
            after_rerendering = element.text
            expect(before_rerendering).not_to eq(after_rerendering)
          end
        end

      end
    end

  end


end
