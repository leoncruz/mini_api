# frozen_string_literal: true

require 'test_helper'
require 'api_responder/model_responder_test'

class SuccessOperationsTest < ModelResponderTest
  test 'should return active record instance when there is no model errors' do
    post '/dummy', params: { first_name: 'Dummy', last_name: 'Record' }

    assert_equal response.parsed_body['data'], DummyRecord.last.as_json
  end

  test 'should return status code 201 and default message when record was created' do
    post '/dummy', params: { first_name: 'Dummy', last_name: 'Record' }

    assert_response :created

    assert_equal 'Dummy Record Translated was successfully created.', response.parsed_body['message']
  end

  test 'should return status code 200 and default message when record was updated' do
    dummy = DummyRecord.create(first_name: 'Dummy', last_name: 'Record')

    DummyRecordsController.class_eval do
      def update
        record = DummyRecord.find(params[:id])

        record.update first_name: 'Record'

        render_json record
      end
    end

    Rails.application.routes.draw { patch '/dummy', to: 'dummy_records#update' }

    patch '/dummy', params: { id: dummy.id }

    assert_response :ok

    assert_equal 'Dummy Record Translated was successfully updated.', response.parsed_body['message']
  end

  test 'should return empty body and 204 status code' do
    dummy = DummyRecord.create(first_name: 'Dummy', last_name: 'Record')

    DummyRecordsController.class_eval do
      def destroy
        record = DummyRecord.find(params[:id])

        record.destroy

        render_json record
      end
    end

    Rails.application.routes.draw { delete '/dummy', to: 'dummy_records#destroy' }

    delete '/dummy', params: { id: dummy.id }

    assert_response :no_content

    assert_empty response.parsed_body
  end
end
