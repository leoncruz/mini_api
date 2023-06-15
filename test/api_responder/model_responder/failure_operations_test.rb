# frozen_string_literal: true

require 'test_helper'
require 'api_responder/model_responder_test'

class FailureOperationsTest < ModelResponderTest
  test 'should return active record errors when there is model errors' do
    post '/dummy', params: { first_name: '', last_name: '' }

    errors = {
      'first_name' => ["can't be blank"],
      'last_name' => ["can't be blank"]
    }

    assert_equal response.parsed_body['errors'], errors
  end

  test 'should return unprocessable entity status when custom status not informed' do
    post '/dummy', params: { first_name: '', last_name: '' }

    assert_response :unprocessable_entity
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
  end

  test 'should return a default message when not informed' do
    post '/dummy', params: { first_name: '', last_name: '' }

    assert_equal 'DummyRecord could not be created.', response.parsed_body['message']
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
  end
end
