# frozen_string_literal: true

require 'test_helper'

class DummyRecordsController < ActionController::Base
  include MiniApi

  def create
    dummy_params = { first_name: params[:first_name], last_name: params[:last_name] }

    dummy_record = DummyRecord.new(dummy_params)

    dummy_record.save

    render_json dummy_record
  end
end

class ModelResponderTest < ActionDispatch::IntegrationTest
  setup do
    ActiveRecord::Base.connection.create_table :dummy_records do |t|
      t.string :first_name
      t.string :last_name
    end

    Rails.application.routes.disable_clear_and_finalize = true

    Rails.application.routes.draw { post '/dummy', to: 'dummy_records#create' }
  end

  teardown do
    ActiveRecord::Base.connection.drop_table(:dummy_records, if_exists: true)

    Rails.application.reload_routes!
  end
end
