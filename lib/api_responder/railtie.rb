# frozen_string_literal: true

require 'active_support/i18n'

module ApiResponder
  class Railtie < ::Rails::Railtie
    # load translations
    I18n.load_path << File.expand_path('../api_responder/locales/en.yml', __dir__)
  end
end
