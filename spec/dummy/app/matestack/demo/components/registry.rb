module Demo::Components::Registry
  Matestack::Ui::Component.register(
    header: Demo::Components::Header,
    isolate_test: Demo::Components::IsolateTest,
  )
end