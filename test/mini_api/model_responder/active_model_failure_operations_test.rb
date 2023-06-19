# frozen_string_literal: true

require 'test_helper'
require 'mini_api/model_responder_test'

class DummyModel
  include ActiveModel::Model

  attr_accessor :first_name, :last_name

  def save
    errors.add(:first_name, :invalid)
    errors.add(:last_name, :invalid)
  end
end

class DummyModelSerializer < ActiveModelSerializers::Model
  attributes :first_name, :last_name
end

class DummyModelsController < ActionController::Base
  include MiniApi

  def create
    dummy_params = { first_name: params[:first_name], last_name: params[:last_name] }

    dummy_model = DummyModel.new(dummy_params)

    dummy_model.save

    render_json dummy_model
  end
end

class ActiveModelFailureOperationsTest < ModelResponderTest
  setup do
    Rails.application.routes.draw { post '/create', to: 'dummy_models#create' }
  end

  teardown do
    Rails.application.reload_routes!
  end

  test 'should return default response when resource is an active model' do
    post '/create', params: { first_name: 'Dummy', last_name: 'Model' }

    assert_response :unprocessable_entity

    refute response.parsed_body['success']

    errors = {
      first_name: ['is invalid'],
      last_name: ['is invalid']
    }.stringify_keys

    assert_equal response.parsed_body['errors'], errors
  end

  test 'should return active model errors as camel lower when configured' do
    MiniApi::Config.transform_response_keys_to = :camel_lower

    post '/create', params: { first_name: 'Dummy', last_name: 'Model' }

    assert_response :unprocessable_entity

    refute response.parsed_body['success']

    errors = {
      firstName: ['is invalid'],
      lastName: ['is invalid']
    }.stringify_keys

    assert_equal response.parsed_body['errors'], errors

    MiniApi::Config.transform_response_keys_to = :snake_case
  end
end
