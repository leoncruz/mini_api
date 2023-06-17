# frozen_string_literal: true

require 'test_helper'

class DefaultController < ActionController::Base
  include MiniApi

  def index
    render_json [1, 2, :symbol, 'House']
  end

  def show
    render_json({ code: 441 }, message: 'could not be resolved')
  end
end

class DefaultResponderTest < ActionDispatch::IntegrationTest
  setup do
    Rails.application.routes.disable_clear_and_finalize = true

    Rails.application.routes.draw do
      get '/', to: 'default#index'
      get '/show', to: 'default#show'
    end
  end

  teardown do
    Rails.application.reload_routes!
  end

  test 'should render array as resource' do
    get '/'

    assert_response :ok

    assert_equal [1, 2, 'symbol', 'House'], response.parsed_body['data']
  end

  test 'should return success as true if not informed' do
    get '/'

    assert_response :ok

    assert response.parsed_body['success']
  end

  test 'should return custom success if informed' do
    DefaultController.class_eval do
      def custom_success
        render_json [1, 2, :symbol, 'House'], success: false
      end
    end

    Rails.application.routes.draw { get '/custom_success', to: 'default#custom_success' }

    get '/custom_success'

    assert_response :ok

    refute response.parsed_body['success']
  end

  test 'should render hash as resource' do
    get '/show'

    assert_response :ok

    assert_equal({ 'code' => 441 }, response.parsed_body['data'])
  end

  test 'should return custom message if informed' do
    get '/show'

    assert_response :ok

    assert_equal 'could not be resolved', response.parsed_body['message']
  end

  test 'should return custom status code if informed' do
    DefaultController.class_eval do
      def custom_status
        render_json 1, status: :not_found
      end
    end

    Rails.application.routes.draw { get '/custom_status', to: 'default#custom_status' }

    get '/custom_status'

    assert_response :not_found
  end
end
