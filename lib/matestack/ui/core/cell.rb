module Matestack
  module Ui
    module Core
      # Custom Cell options/handling based on a Cell from the cells gem.
      #
      # Needed to redefine some options and gives us more control over
      # the cells.
      module Cell
        include ::Cell::Haml

        # based on https://github.com/trailblazer/cells-haml/blob/master/lib/cell/haml.rb
        # be aware that as of February 2020 this differs from the released version though.
        def template_options_for(_options)
          # Note, cells uses Hash#delete which mutates the hash,
          # hence we can't use a constant here as on the first
          # invocation it'd lose it's suffix key
          {
            template_class: ::Tilt::HamlTemplate,
            escape_html:    true,
            escape_attrs:   true,
            suffix:         "haml"
          }
        end

        def html_escape(string)
          ERB::Util.html_escape(string)
        end
      end
    end
  end
end
