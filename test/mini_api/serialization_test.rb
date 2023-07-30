# frozen_string_literal: true

require 'test_helper'

class SerializationTest < ActionDispatch::IntegrationTest
  setup do
    ActiveRecord::Base.connection.create_table :dummy_records do |t|
      t.string :first_name
      t.string :last_name
    end

    1.upto(2) do |n|
      DummyRecord.create(first_name: "Dummy #{n}", last_name: "Record #{n}")
    end

    Rails.application.routes.disable_clear_and_finalize = true
  end

  teardown do
    ActiveRecord::Base.connection.drop_table(:dummy_records, if_exists: true)

    Rails.application.reload_routes!
  end
end

module WithDefinedResource
  class DummiesController < ActionController::Base
    include MiniApi

    def index
      dummies = DummyRecord.all

      render_json dummies
    end

    def show
      dummy = DummyRecord.first

      render_json dummy
    end
  end

  class DummyRecordResource
    include Alba::Resource

    attributes :id, :first_name, :last_name
  end

  class BasicControllerAndResource < SerializationTest
    setup do
      Rails.application.routes.draw do
        get '/', to: 'with_defined_resource/dummies#index'
        get '/show', to: 'with_defined_resource/dummies#show'
      end
    end

    test 'should use serializer when avaliable to render collections' do
      get '/'

      assert_response :ok

      dummies = [
        {
          id: 1,
          first_name: 'Dummy 1',
          last_name: 'Record 1'
        }.stringify_keys,
        {
          id: 2,
          first_name: 'Dummy 2',
          last_name: 'Record 2'
        }.stringify_keys
      ]

      assert_equal dummies, response.parsed_body['data']
    end

    test 'should use serializer when avaliable to render single instances' do
      get '/show'

      assert_response :ok

      dummy = {
        id: 1,
        first_name: 'Dummy 1',
        last_name: 'Record 1'
      }.stringify_keys

      assert_equal dummy, response.parsed_body['data']
    end
  end

  module Api
    module V1
      class DummiesController < ActionController::Base
        include MiniApi

        def index
          dummies = DummyRecord.all

          render_json dummies
        end
      end

      class DummyRecordResource
        include Alba::Resource

        attributes :last_name
      end

      class NestedControllerAndResource < SerializationTest
        setup do
          Rails.application.routes.draw do
            get '/api/v1/dummies', to: 'with_defined_resource/api/v1/dummies#index'
          end
        end

        test 'should use nested serializer for nested controller' do
          get '/api/v1/dummies'

          assert_response :ok

          data = [
            { 'last_name' => DummyRecord.first.last_name },
            { 'last_name' => DummyRecord.last.last_name }
          ]

          assert_equal response.parsed_body['data'], data
        end
      end
    end
  end

  module Different
    class DummyRecordResource
      include Alba::Resource

      attributes :first_name
    end

    module Scope
      class DummiesController < ActionController::Base
        include MiniApi

        def index
          dummies = DummyRecord.all

          render_json dummies
        end
      end

      class DifferentScope < SerializationTest
        setup do
          Rails.application.routes.draw do
            get '/dummies', to: 'with_defined_resource/different/scope/dummies#index'
          end
        end

        test 'should find resource when controller is in different module tree' do
          get '/dummies'

          assert_response :ok

          data = [
            { 'first_name' => DummyRecord.first.first_name },
            { 'first_name' => DummyRecord.last.first_name }
          ]

          assert_equal response.parsed_body['data'], data
        end
      end
    end
  end
end

module DefaultResourceRenderer
  class DummiesController < ActionController::Base
    include MiniApi

    def show
      dummy = DummyRecord.first

      render_json dummy
    end
  end

  class DefaultResourceRendererTest < SerializationTest
    setup do
      Rails.application.routes.draw do
        get '/dummy', to: 'default_resource_renderer/dummies#show'
      end
    end

    test 'should use DefaultResource class when does not have an defined resource' do
      get '/dummy'

      dummy = DummyRecord.first

      expected_data = {
        'id' => dummy.id,
        'first_name' => dummy.first_name,
        'last_name' => dummy.last_name
      }

      assert_equal response.parsed_body['data'], expected_data
    end
  end
end
