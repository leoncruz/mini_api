# frozen_string_literal: true

require 'mini_api/serialization'
require 'mini_api/case_transform'

module MiniApi
  # class to handle json render of ActiveRecord::Base instances and ActiveModel::Model's
  class ModelResponder
    include Serialization

    def initialize(controller, resource, options = {})
      @controller = controller
      @resource = resource
      @options = options
    end

    def respond
      body = {
        success: resource_has_errors? == false,
        message: @options[:message] || default_message
      }

      body =
        if resource_has_errors?
          errors.merge(body)
        else
          { data: serialiable_body(@resource).as_json }.merge(body)
        end

      # This is for an problem with ActiveModelSerializer that adds an error
      # attribute when resource is an ActiveModel instance
      body[:data] = body[:data].except('errors') if body[:data]&.key?('errors')

      body = CaseTransform.response_keys(body)

      @controller.render json: body, status: status_code
    end

    private

    def resource_has_errors?
      !@resource.errors.empty?
    end

    def errors
      error_serializer = get_error_serializer(@resource)

      return { errors: @resource.errors.messages } unless error_serializer

      { errors: error_serializer.new(@resource).as_json }
    end

    def status_code
      return @options[:status] if @options[:status].present?

      return :unprocessable_entity if resource_has_errors?

      return :created if previously_new_record?

      return :no_content if destroyed?

      :ok
    end

    def default_message
      kind = resource_has_errors? ? 'alert' : 'notice'

      model_path = "mini_api.messages.#{@resource.model_name.i18n_key}"

      if I18n.exists? model_path
        I18n.t(
          kind,
          scope: "#{model_path}.#{@controller.action_name}",
          resource_name: @resource.class.model_name.human,
          default: ''
        )
      else
        I18n.t(
          kind,
          scope: [:mini_api, :messages, :actions, @controller.action_name],
          resource_name: @resource.class.model_name.human,
          default: ''
        )
      end
    end

    def previously_new_record?
      return true if @resource.is_a?(ActiveRecord::Base) && @resource.previously_new_record?

      false
    end

    def destroyed?
      return true if @resource.is_a?(ActiveRecord::Base) && !@resource.persisted?

      false
    end
  end
end
