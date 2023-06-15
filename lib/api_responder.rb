# frozen_string_literal: true

require 'api_responder/railtie'
require 'api_responder/responder'

# Entrypoint module
module ApiResponder
  def render_json(resource, options = {})
    responder = Responder.new(self, resource, options)

    responder.respond
  end
end
