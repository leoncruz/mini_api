# frozen_string_literal: true

module ApiResponder
  class RelationResponder
    def initialize(controller, resource, options = {})
      @controller = controller
      @resource = resource
      @options = options
    end

    def respond
      @controller.render json: @resource, status: options[:status]
    end
  end
end
