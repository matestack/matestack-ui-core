module Components::Registry

  Matestack::Ui::Core::Component::Registry.register_components(
    my_card: Components::Card,
    some_card: Components::Card,
    some_other_card: Components::Card,
    some_stupid_card: Components::Card,
    some_fancy_card: Components::Fancy::Card,
    legacy_views_pages_async: Components::LegacyViews::Pages::Async,
    legacy_views_pages_action: Components::LegacyViews::Pages::Action,
    legacy_views_pages_collection: Components::LegacyViews::Pages::Collection,
    legacy_views_pages_form: Components::LegacyViews::Pages::Form,
    legacy_views_pages_onclick: Components::LegacyViews::Pages::Onclick,
    legacy_views_pages_isolated: Components::LegacyViews::Pages::Isolated,
  )

end
