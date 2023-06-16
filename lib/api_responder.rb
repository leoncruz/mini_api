# frozen_string_literal: true

require 'api_responder/railtie'
require 'api_responder/responder'

# Entrypoint module
module ApiResponder
  def render_json(resource, options = {})
    responder = Responder.new(self, resource, options)

    responder.respond
  end

  def page
    params[:page].to_i || 1
  end

  def per_page
    if params[:per_page].to_i.in?([10, 25, 50, 100])
      params[:per_page]
    else
      25
    end
  end
end
