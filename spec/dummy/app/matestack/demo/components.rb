module Demo
  module Components

    def header(options = nil)
      Demo::Components::Header.(options)
    end

    def isolate_test(options = nil)
      Demo::Components::IsolateTest.(options)
    end

    def some_component(options = nil)
      Demo::Components::SomeComponent.(options)
    end

    def foobar(options = nil)
      Demo::Components::Tes.(options)
    end

  end
end