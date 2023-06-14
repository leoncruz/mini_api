# frozen_string_literal: true

module ApiResponder
  class DefaultResponder
    def initialize(controller, resource, options = {})
      @controller = controller
      @resource = resource
      @options = options
    end

    def respond; end
  end
end
