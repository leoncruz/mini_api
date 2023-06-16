# frozen_string_literal: true

require 'api_responder/exceptions/kaminari_not_installed'

module ApiResponder
  class RelationResponder
    def initialize(controller, resource, options = {})
      @controller = controller
      @resource = resource
      @options = options
    end

    def respond
      meta, collection = extract_meta_and_collection(@resource)

      @controller.render json: {
        success: @options[:success] || true,
        data: collection,
        meta: meta
      }, status: @options[:status]
    end

    private

    def extract_meta_and_collection(resource)
      collection = transform_resource_to_collection(resource)

      [
        {
          current_page: collection.current_page,
          next_page: collection.next_page,
          prev_page: collection.prev_page,
          total_pages: collection.total_pages,
          total_records: collection.total_count
        },
        collection
      ]
    end

    def transform_resource_to_collection(resource)
      unless defined?(Kaminari)
        raise KaminariNotInstalled, 'The Kaminari gem is not installed. Install to perform pagination operations'
      end

      resource.page(@controller.page).per(@controller.per_page)
    end
  end
end
