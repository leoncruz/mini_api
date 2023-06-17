# frozen_string_literal: true

require 'mini_api/serialization'

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
          { errors: @resource.errors.messages }.merge(body)
        else
          { data: serialiable_body(@resource) }.merge(body)
        end

      @controller.render json: body, status: status_code
    end

    private

    def resource_has_errors?
      !@resource.errors.empty?
    end

    def status_code
      return @options[:status] if @options[:status].present?

      return :unprocessable_entity if resource_has_errors?

      return :created if @resource.previously_new_record?

      return :no_content unless @resource.persisted?

      :ok
    end

    def default_message
      kind = resource_has_errors? ? 'alert' : 'notice'

      I18n.t(
        kind,
        scope: [:mini_api, :messages, :actions, @controller.action_name],
        resource_name: @resource.class.model_name.human,
        default: ''
      )
    end
  end
end
