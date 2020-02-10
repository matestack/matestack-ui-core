module Matestack::Ui::Core::HasScopedI18n

  # ## Adding scoped translations to matestack ("lazy lookup").
  #
  # This is a namespacing mechanism for translations.
  #
  # Consider this locale:
  #
  #     # config/locales/sessions/en.yml
  #     en:
  #       sessions:
  #         new:
  #           sign_in: Sign in
  #           email: Email
  #           password: Password
  #
  # These translations usually can be accessed via their full key:
  #
  #     translate 'sessions.new.sign_in'  # => "Sign in"
  #
  # Inside pages rendered from the `sessions#new` controller action,
  # these translations can be accessed via the following short form:
  #
  #     translate '.sign_in'  # => "Sign in"
  #
  # This mirrors the convention provided by rails for views and controllers:
  # https://guides.rubyonrails.org/i18n.html#lazy-lookup
  #
  def translate(*args)
    key = args.first
    if key.is_a?(String) && (key[0] == '.')
      key = "#{ controller_path.gsub('/', '.') }.#{ action_name }#{ key }"
      args[0] = key
    end
    super(*args)
  end

  def t(*args)
    translate(*args)
  end

end
