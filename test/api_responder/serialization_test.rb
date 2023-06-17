# frozen_string_literal: true

require 'test_helper'

class DummiesController < ActionController::Base
  include ApiResponder

  def index
    dummies = DummyRecord.all

    render_json dummies
  end

  def show
    dummy = DummyRecord.first

    render_json dummy
  end
end

class DummySerializer < ActiveModel::Serializer
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

    Rails.application.routes.draw do
      get '/', to: 'dummies#index'
      get '/show', to: 'dummies#show'
    end
  end

  teardown do
    ActiveRecord::Base.connection.drop_table(:dummy_records, if_exists: true)

    Rails.application.reload_routes!
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
