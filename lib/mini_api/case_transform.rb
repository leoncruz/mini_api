# frozen_string_literal: true

require 'mini_api/config'
require 'mini_api/exceptions/case_transform_option_invalid'

module MiniApi
  module CaseTransform
    module_function

    def transform(object = {})
      transform_keys_to = MiniApi::Config.transform_keys_to

      object.deep_transform_keys do |key|
        case transform_keys_to
        when :camel_case
          key.to_s.camelize
        when :camel_lower
          key.to_s.camelize(:lower)
        when :snake_case
          key.to_s.underscore
        else
          raise CaseTransformOptionInvalid, "option #{transform_keys_to} is not supported."
        end
      end
    end
  end
end
