# frozen_string_literal: true

require 'mini_api/config'
require 'mini_api/exceptions/case_transform_option_invalid'

module MiniApi
  module CaseTransform
    module_function

    def transform(object, transform_to = :snake_case)
      object.deep_transform_keys do |key|
        case transform_to
        when :camel_case
          key.to_s.camelize
        when :camel_lower
          key.to_s.camelize(:lower)
        when :snake_case
          key.to_s.underscore
        else
          raise CaseTransformOptionInvalid, "option #{transform_to} is not supported."
        end
      end
    end

    def request_params_keys(params)
      transform(params, Config.transform_params_keys_to)
    end

    def response_keys(response)
      transform(response, Config.transform_response_keys_to)
    end
  end
end
