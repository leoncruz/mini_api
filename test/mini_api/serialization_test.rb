# frozen_string_literal: true

require 'test_helper'

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

class BasicControllerAndResource < SerializationTest
  setup do
    Rails.application.routes.draw do
      get '/', to: 'dummies#index'
      get '/show', to: 'dummies#show'
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

    class NestedControllerAndResource < ::SerializationTest
      setup do
        Rails.application.routes.draw do
          namespace :api do
            namespace :v1 do
              get '/dummies', to: 'dummies#index'
            end
          end
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
          namespace :different do
            namespace :scope do
              get '/dummies', to: 'dummies#index'
            end
          end
        end
      end

      test 'should find resource when controller is in different module tree' do
        get '/different/scope/dummies'

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
