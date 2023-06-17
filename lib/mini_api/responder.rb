# frozen_string_literal: true

require 'mini_api/default_responder'
require 'mini_api/model_responder'
require 'mini_api/relation_responder'

module MiniApi
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
