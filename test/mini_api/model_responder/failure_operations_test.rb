# frozen_string_literal: true

require 'test_helper'
require 'mini_api/model_responder_test'

class FailureOperationsTest < ModelResponderTest
  test 'should return active record errors when there is model errors' do
    post '/dummy', params: { first_name: '', last_name: '' }

    errors = {
      'first_name' => ["can't be blank"],
      'last_name' => ["can't be blank"]
    }

    assert_equal response.parsed_body['errors'], errors
    assert_not response.parsed_body['success']
  end

  test 'should return unprocessable entity status when custom status not informed' do
    post '/dummy', params: { first_name: '', last_name: '' }

    assert_response :unprocessable_entity
    assert_not response.parsed_body['success']
  end

  test 'should return custom status when informed' do
    DummyRecordsController.class_eval do
      def create_with_default_status
        dummy_params = { first_name: params[:first_name], last_name: params[:last_name] }

        dummy_record = DummyRecord.new(dummy_params)

        dummy_record.save

        render_json dummy_record, status: :bad_request
      end
    end

    Rails.application.routes.draw do
      post '/create_with_default_status', to: 'dummy_records#create_with_default_status'
    end

    post '/create_with_default_status', params: { first_name: '', last_name: '' }

    assert_response :bad_request
    assert_not response.parsed_body['success']
  end

  test 'should return a default message when not informed' do
    post '/dummy', params: { first_name: '', last_name: '' }

    assert_equal 'Dummy Record Translated could not be created.', response.parsed_body['message']
    assert_not response.parsed_body['success']
  end

  test 'should return custom message when informed' do
    DummyRecordsController.class_eval do
      def create_with_custom_message
        dummy_params = { first_name: params[:first_name], last_name: params[:last_name] }

        dummy_record = DummyRecord.new(dummy_params)

        dummy_record.save

        render_json dummy_record, message: 'Custom message error'
      end
    end

    Rails.application.routes.draw do
      post '/create_with_custom_message', to: 'dummy_records#create_with_custom_message'
    end

    post '/create_with_custom_message', params: { first_name: '', last_name: '' }

    assert_equal 'Custom message error', response.parsed_body['message']

    assert_not response.parsed_body['success']
  end

  test 'should active record errors with camel lower keys when configured' do
    MiniApi::Config.transform_response_keys_to = :camel_lower

    post '/dummy', params: { first_name: '', last_name: '' }

    errors = {
      'firstName' => ["can't be blank"],
      'lastName' => ["can't be blank"]
    }

    assert_equal response.parsed_body['errors'], errors

    MiniApi::Config.transform_response_keys_to = :snake_case
  end
end
