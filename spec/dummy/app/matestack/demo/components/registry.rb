module Demo::Components::Registry
  Matestack::Ui::Component.register(
    header: Demo::Components::Header,
    isolate_test: Demo::Components::IsolateTest,
    some_component: Demo::Components::SomeComponent,
    foobar: Demo::Components::Test,
  )
end