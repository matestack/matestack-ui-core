module Demo::Components::Registry

  Matestack::Ui::Core::Component::Registry.register_components(
    my_demo_card: Demo::Components::Card,
    fancy_stuff: Demo::Components::FancyStuff,
    foo_fancy_stuff: Demo::Components::Foo::FancyStuff,
  )

end
