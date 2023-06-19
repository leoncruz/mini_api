# frozen_string_literal: true

module MiniApi
  class Config
    include ActiveSupport::Configurable

    # permitted values are: [:camel_case, :camel_lower, snake_case]
    config_accessor :transform_params_keys_to, instance_accessor: false, default: :snake_case
    config_accessor :transform_response_keys_to, instance_accessor: false, default: :snake_case
  end
end
