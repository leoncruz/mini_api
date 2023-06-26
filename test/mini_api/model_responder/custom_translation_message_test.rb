# frozen_string_literal: true

require 'test_helper'
require 'mini_api/model_responder_test'

class DummyCustomTranslation < ActiveRecord::Base
  self.table_name = 'dummy_records'

  validates :first_name, presence: true
  validates :last_name, presence: true
end

class DummyCustomTranslationsController < ActionController::Base
  include MiniApi

  def create
    dummy_params = { first_name: params[:first_name], last_name: params[:last_name] }

    dummy_record = DummyCustomTranslation.new(dummy_params)

    dummy_record.save

    render_json dummy_record
  end
end

class MessagesController < ActionController::Base
  include MiniApi

  def create
    dummy_params = { first_name: params[:first_name], last_name: params[:last_name] }

    dummy_record = DummyRecord.new(dummy_params)

    dummy_record.save

    render_json dummy_record
  end
end

class CustomTranslationMessageTest < ModelResponderTest
  setup do
    Rails.application.routes.draw do
      post '/create', to: 'dummy_custom_translations#create'
      post '/controller_messages/create', to: 'messages#create'
    end
  end

  teardown { Rails.application.reload_routes! }

  test 'should use translation with model name when defined for success actions' do
    post '/create', params: { first_name: 'Dummy', last_name: 'Translation' }

    assert_response :created

    assert_equal 'was created!', response.parsed_body['message']
  end

  test 'should use translation with model name when defined for failure actions' do
    post '/create', params: { first_name: 'Dummy', last_name: nil }

    assert_response :unprocessable_entity

    assert_equal 'something was wrong!', response.parsed_body['message']
  end

  test 'should use controller translations when defined' do
    post '/controller_messages/create', params: { first_name: 'Dummy', last_name: 'Record' }

    assert_equal 'message controller notice', response.parsed_body['message']

    post '/controller_messages/create', params: {}

    assert_equal 'message controller alert', response.parsed_body['message']
  end
end
