# frozen_string_literal: true

require 'active_support/i18n'

module MiniApi
  class Railtie < ::Rails::Railtie
    # load translations
    I18n.load_path << File.expand_path('../mini_api/locales/en.yml', __dir__)
  end
end
