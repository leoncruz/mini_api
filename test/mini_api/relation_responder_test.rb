# frozen_string_literal: true

require 'test_helper'

class DummyRecordsController < ActionController::Base
  include MiniApi

  def index
    dummies = DummyRecord.all

    render_json dummies
  end
end

class RelationResponder < ActionDispatch::IntegrationTest
  setup do
    ActiveRecord::Base.connection.create_table :dummy_records do |t|
      t.string :first_name
      t.string :last_name
    end

    Rails.application.routes.disable_clear_and_finalize = true

    Rails.application.routes.draw { get '/dummies', to: 'dummy_records#index' }
  end

  teardown do
    ActiveRecord::Base.connection.drop_table(:dummy_records, if_exists: true)

    Rails.application.reload_routes!
  end

  test 'should return json with response keys' do
    get '/dummies'

    assert_response :ok

    assert_includes response.parsed_body, 'data'
    assert_includes response.parsed_body, 'success'
    assert_includes response.parsed_body, 'meta'
    assert_includes response.parsed_body['meta'], 'current_page'
    assert_includes response.parsed_body['meta'], 'next_page'
    assert_includes response.parsed_body['meta'], 'prev_page'
    assert_includes response.parsed_body['meta'], 'total_pages'
    assert_includes response.parsed_body['meta'], 'total_records'
  end

  test 'should return meta key with pagination information' do
    DummyRecord.create(first_name: 'Dummy', last_name: 'Record')

    get '/dummies'

    meta = {
      current_page: 1,
      next_page: nil,
      prev_page: nil,
      total_pages: 1,
      total_records: 1
    }.stringify_keys

    assert_response :ok

    assert_equal response.parsed_body['meta'], meta
  end

  test 'should paginate data when page and per_page are informed' do
    1.upto(30) { |n| DummyRecord.create(first_name: "Dummy #{n}", last_name: "Record #{n}") }

    get '/dummies?page=1&per_page=10'

    assert_response :ok

    assert_equal 10, response.parsed_body['data'].size

    assert_equal({
      current_page: 1,
      next_page: 2,
      prev_page: nil,
      total_pages: 3,
      total_records: 30
    }.stringify_keys, response.parsed_body['meta'])

    get '/dummies?page=2&per_page=10'

    assert_response :ok

    assert_equal 10, response.parsed_body['data'].size

    assert_equal({
      current_page: 2,
      next_page: 3,
      prev_page: 1,
      total_pages: 3,
      total_records: 30
    }.stringify_keys, response.parsed_body['meta'])

    get '/dummies?page=3&per_page=10'

    assert_response :ok

    assert_equal 10, response.parsed_body['data'].size

    assert_equal({
      current_page: 3,
      next_page: nil,
      prev_page: 2,
      total_pages: 3,
      total_records: 30
    }.stringify_keys, response.parsed_body['meta'])
  end

  test 'should return default per_page value of 25 when not informed on params' do
    1.upto(30) { |n| DummyRecord.create(first_name: "Dummy #{n}", last_name: "Record #{n}") }

    get '/dummies'

    assert_response :ok

    assert_equal 25, response.parsed_body['data'].size
  end

  test 'should return default per_page value of 25 when param informed is not a permitted value' do
    1.upto(30) { |n| DummyRecord.create(first_name: "Dummy #{n}", last_name: "Record #{n}") }

    get '/dummies?per_page=5'

    assert_response :ok

    assert_equal 25, response.parsed_body['data'].size
  end

  test 'should return keys as camel_lower when configured' do
    MiniApi::Config.transform_response_keys_to = :camel_lower

    1.upto(25) { |n| DummyRecord.create(first_name: "Dummy #{n}", last_name: "Record #{n}") }

    get '/dummies'

    assert_response :ok

    response.parsed_body['data'].each do |dummy|
      assert_equal %w[id firstName lastName], dummy.keys
    end

    MiniApi::Config.transform_response_keys_to = :snake_case
  end

  test 'should return metadata keys as camel_lower when configured' do
    MiniApi::Config.transform_response_keys_to = :camel_lower

    DummyRecord.create(first_name: 'Dummy', last_name: 'Record')

    get '/dummies'

    assert_response :ok

    assert_equal %w[currentPage nextPage prevPage totalPages totalRecords], response.parsed_body['meta'].keys

    MiniApi::Config.transform_response_keys_to = :snake_case
  end
end
