# frozen_string_literal: true

module MiniApi
  module Translation
    # Module to handle the +message+ key on json response.
    # Will identify if model has errors or not and define the I18n path to +notice+, for model without errors
    # and +alert+ for model with errors.
    # There is three possible path for messages:
    #
    # The path based on model name
    # mini_api:
    #   messages:
    #     model_name:
    #       action_name:
    #         notitce:
    #         alert:
    #
    # The path based on controller name
    # mini_api:
    #   messages:
    #     controller:
    #       controller_name:
    #         action_name:
    #           notitce:
    #           alert:
    #
    # And the last, is per action path:
    # mini_api:
    #   messages:
    #     actions:
    #       create:
    #         notice: '%{resource_name} foi criado com sucesso.'
    #         alert: '%{resource_name} não pôde ser criado.'

    module Message
      def i18n_message
        kind = @resource.errors.empty? ? 'notice' : 'alert'

        I18n.t(
          kind,
          scope: model_message_path || controller_message_path || default_message_path,
          resource_name: @resource.class.model_name.human,
          default: ''
        )
      end

      private

      def model_message_path
        model_path = "mini_api.messages.#{@resource.model_name.i18n_key}.#{@controller.action_name}"

        model_path if I18n.exists? model_path
      end

      def controller_message_path
        controller_path =
          "mini_api.messages.controller.#{@controller.controller_name}.#{@controller.action_name}"

        controller_path if I18n.exists? controller_path
      end

      def default_message_path
        ['mini_api', 'messages', 'actions', @controller.action_name].join('.')
      end
    end
  end
end
