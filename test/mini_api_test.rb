# frozen_string_literal: true

require 'test_helper'

class DummyModel
  include ActiveModel::Model

  attr_accessor :first_name, :last_name
end

class MiniTestController < ActionController::Base
  include MiniApi

  def new
    dummy = DummyModel.new(first_name: params[:first_name], last_name: params[:last_name])

    render_json dummy
  end

  def camel_lower
    dummy = DummyModel.new(first_name: params[:firstName], last_name: params[:firstName])

    render_json dummy
  end

  def camel_case
    dummy = DummyModel.new(first_name: params[:FirstName], last_name: params[:FirstName])

    render_json dummy
  end
end

class MiniApiTest < ActionDispatch::IntegrationTest
  setup do
    Rails.application.routes.draw do
      get '/new', to: 'mini_test#new'
      get '/camel_lower', to: 'mini_test#camel_lower'
    end
  end

  test 'should transform params to snake case if no config was provided' do
    get '/new', params: { 'firstName' => 'Dummy', 'lastName' => 'Model' }

    assert_response :ok
  end

  test 'should transform keys to camelLower when configured' do
    MiniApi::Config.transform_keys_to = :camel_lower

    get '/new', params: { 'first_name' => 'Dummy', 'last_name' => 'Model' }

    assert_response :ok

    MiniApi::Config.transform_keys_to = :snake_case
  end

  test 'should transform keys to CamelCase when informed' do
    MiniApi::Config.transform_keys_to = :camel_case

    get '/new', params: { 'first_name' => 'Dummy', 'last_name' => 'Model' }

    assert_response :ok

    MiniApi::Config.transform_keys_to = :snake_case
  end
end
