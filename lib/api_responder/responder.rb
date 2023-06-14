# frozen_string_literal: true

require 'api_responder/default_responder'
require 'api_responder/model_responder'
require 'api_responder/relation_responder'

module ApiResponder
  class Responder
    def initialize(controller, resource, options = {})
      @controller = controller
      @resource = resource
      @options = options
    end

    def respond
      case @resource
      when ActiveRecord::Relation
        relation_responder.respond
      when ActiveRecord::Base, ActiveModel::Model
        model_responder.respond
      else
        default_responder.respond
      end
    end

    def relation_responder
      RelationResponder.new(@controller, @resource, @options)
    end

    def model_responder
      ModelResponder.new(@controller, @resource, @options)
    end

    def default_responder
      DefaultResponder.new(@controller, @resource, @options)
    end
  end
end
