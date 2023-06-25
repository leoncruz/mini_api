# frozen_string_literal: true

require 'alba'

module MiniApi
  module Serialization
    # This method search by serializer using the module parents of controller.
    # With this, is possible define serializers for the same resource
    # in different controller scopes
    def serialiable_body(resource)
      controller_scope = @controller.class.module_parents

      resource_class =
        if resource.respond_to?(:model)
          resource.model
        else
          resource.class
        end

      serializer_class =
        loop do
          serializer_class =
            "#{controller_scope.first}::#{resource_class}Resource".safe_constantize

          break serializer_class if serializer_class

          break DefaultResource if controller_scope.empty?

          controller_scope.shift
        end

      serializer_class.new(resource)
    end

    # Search by the nested class +Error+ on serializer
    # Follow the same steps for +get_serializer+
    def get_error_serializer(resource)
      error_serializer = serialiable_body(resource)

      return unless error_serializer

      "#{error_serializer.class}::Error".safe_constantize
    end

    # Empty serializer class for when resource does not have a custom class
    class DefaultResource
      include Alba::Resource
    end
  end
end
