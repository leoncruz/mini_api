# frozen_string_literal: true

require 'test_helper'
require 'mini_api/model_responder_test'

class DummyModel
  include ActiveModel::Model

  attr_accessor :first_name, :last_name
end

class DummyModelResource
  include Alba::Resource

  attributes :first_name, :last_name
end

class DummyModelsController < ActionController::Base
  include MiniApi

  def show
    dummy_model = DummyModel.new(first_name: 'Dummy', last_name: 'Model')

    render_json dummy_model
  end
end

class ActiveModelSuccessOperationsTest < ModelResponderTest
  setup do
    Rails.application.routes.draw { get '/', to: 'dummy_models#show' }
  end

  teardown do
    Rails.application.reload_routes!
  end

  test 'should return default response when resource is an active model' do
    get '/'

    assert_response :ok

    data = {
      first_name: 'Dummy',
      last_name: 'Model'
    }.stringify_keys

    assert_equal response.parsed_body['data'], data

    assert response.parsed_body['success']
  end

  test 'should return model attributes as camel lower when configured' do
    MiniApi::Config.transform_response_keys_to = :camel_lower

    get '/'

    assert_response :ok

    data = {
      firstName: 'Dummy',
      lastName: 'Model'
    }.stringify_keys

    assert_equal response.parsed_body['data'], data

    assert response.parsed_body['success']

    MiniApi::Config.transform_response_keys_to = :snake_case
  end
end
