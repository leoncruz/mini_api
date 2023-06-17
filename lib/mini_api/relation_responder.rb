# frozen_string_literal: true

require 'mini_api/exceptions/kaminari_not_installed'
require 'mini_api/serialization'

module MiniApi
  class RelationResponder
    include Serialization

    def initialize(controller, resource, options = {})
      @controller = controller
      @resource = resource
      @options = options
    end

    def respond
      meta, collection = extract_meta_and_collection

      @controller.render json: {
        success: @options[:success] || true,
        data: collection,
        meta: meta
      }, status: @options[:status]
    end

    private

    def extract_meta_and_collection
      collection = transform_resource_to_collection

      [
        {
          current_page: collection.current_page,
          next_page: collection.next_page,
          prev_page: collection.prev_page,
          total_pages: collection.total_pages,
          total_records: collection.total_count
        },
        serialiable_body(collection)
      ]
    end

    def transform_resource_to_collection
      unless defined?(Kaminari)
        raise KaminariNotInstalled, 'The Kaminari gem is not installed. Install to perform pagination operations'
      end

      @resource.page(@controller.page).per(@controller.per_page)
    end
  end
end
