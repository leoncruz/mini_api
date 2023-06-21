# frozen_string_literal: true

module MiniApi
  #
  # This module is responsible to handler integration with Active Model Serialier gem
  # call the +get_serializer+ method of controller implemented by gem
  # to find the serializer of informed object.

  module Serialization
    def serialiable_body(resource)
      return resource unless defined?(ActiveModel::Serializer)

      @controller.get_serializer(resource)
    end

    def get_error_serializer(resource)
      serializer_class = @controller.get_serializer(resource)

      "#{serializer_class.serializer}::Error".safe_constantize
    end
  end
end
