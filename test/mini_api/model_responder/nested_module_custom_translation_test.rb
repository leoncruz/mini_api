# frozen_string_literal: true

require 'test_helper'
require 'mini_api/model_responder_test'

module NestedModule
  class DummyCustomTranslation < ActiveRecord::Base
    self.table_name = 'dummy_records'

    validates :first_name, presence: true
    validates :last_name, presence: true
  end

  class DummyCustomTranslationsController < ActionController::Base
    include MiniApi

    def update
      dummy_params = { first_name: params[:first_name], last_name: params[:last_name] }

      dummy_record = DummyCustomTranslation.find(params[:id])

      dummy_record.update(dummy_params)

      render_json dummy_record
    end
  end

  class CustomTranslationMessageTest < ModelResponderTest
    setup do
      Rails.application.routes.draw do
        namespace :nested_module do
          post '/update', to: 'dummy_custom_translations#update'
        end
      end
    end

    teardown { Rails.application.reload_routes! }

    test 'should use translation with model name when defined for success actions' do
      dummy = DummyCustomTranslation.create(first_name: 'Dummy', last_name: 'Record')

      post '/nested_module/update', params: { id: dummy.id, first_name: 'Dummy', last_name: 'Translation' }

      assert_response :ok

      assert_equal 'nested! was created!', response.parsed_body['message']
    end

    test 'should use translation with model name when defined for failure actions' do
      dummy = DummyCustomTranslation.create(first_name: 'Dummy', last_name: 'Record')

      post '/nested_module/update', params: { id: dummy.id, first_name: 'Dummy', last_name: nil }

      assert_response :unprocessable_entity

      assert_equal 'nested! something was wrong!', response.parsed_body['message']
    end
  end
end
