# frozen_string_literal: true

module ApiResponder
  class DefaultResponder
    def initialize(controller, resource, options = {})
      @controller = controller
      @resource = resource
      @options = options
    end

    def respond
      success = @options[:success] != false

      @controller.render(
        json: {
          success: success,
          data: @resource,
          message: @options[:message] || nil
        },
        status: @options[:status] || :ok
      )
    end
  end
end
