# frozen_string_literal: true

require 'mini_api/railtie'
require 'mini_api/responder'
require 'mini_api/case_transform'

# Entrypoint module
module MiniApi
  extend ActiveSupport::Concern

  included do
    include CaseTransform

    before_action :transform_params

    def transform_params
      self.params =
        ActionController::Parameters.new(CaseTransform.request_params_keys(request.parameters))
    end
  end

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
