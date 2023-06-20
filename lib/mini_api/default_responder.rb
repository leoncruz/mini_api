# frozen_string_literal: true

require 'mini_api/case_transform'

module MiniApi
  class DefaultResponder
    def initialize(controller, resource, options = {})
      @controller = controller
      @resource = resource
      @options = options
    end

    def respond
      success = @options[:success] != false

      data = transform_keys

      body =
        if success
          { data: data }
        else
          { errors: data }
        end

      @controller.render(
        json: {
          success: success,
          message: @options[:message] || nil,
          **body
        },
        status: @options[:status] || :ok
      )
    end

    private

    def transform_keys
      return CaseTransform.response_keys(@resource) if @resource.is_a?(Hash)

      return @resource unless @resource.is_a?(Array)

      @resource.map do |item|
        if item.is_a?(Hash)
          CaseTransform.response_keys(item)
        else
          item
        end
      end
    end
  end
end
