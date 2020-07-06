module Components::Registry

  Matestack::Ui::Core::Component::Registry.register_components(
    my_card: Components::Card,
    some_card: Components::Card,
    some_other_card: Components::Card,
    some_stupid_card: Components::Card,
    some_fancy_card: Components::Card
  )

end
