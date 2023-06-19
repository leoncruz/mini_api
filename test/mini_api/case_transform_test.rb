# frozen_string_literal: true

require 'test_helper'

class CaseTransformTest < ActiveSupport::TestCase
  test 'should transform keys to snake case if not configuration is informed' do
    hash = { 'firstName' => 'Some random Name', 'address' => { 'addressNumber' => '10' } }

    result = MiniApi::CaseTransform.transform(hash)

    expected = { 'first_name' => 'Some random Name', 'address' => { 'address_number' => '10' } }

    assert_equal result, expected
  end

  test 'should transform keys to camelLower when informed' do
    MiniApi::Config.transform_keys_to = :camel_lower

    hash = { 'first_name' => 'Some random Name', 'address' => { 'address_number' => '10' } }

    result = MiniApi::CaseTransform.transform(hash)

    expected = { 'firstName' => 'Some random Name', 'address' => { 'addressNumber' => '10' } }

    assert_equal result, expected

    MiniApi::Config.transform_keys_to = :snake_case
  end

  test 'should transform keys to CamelCase when informed' do
    MiniApi::Config.transform_keys_to = :camel_case

    hash = { 'first_name' => 'Some random Name', 'address' => { 'address_number' => '10' } }

    result = MiniApi::CaseTransform.transform(hash)

    expected = { 'FirstName' => 'Some random Name', 'Address' => { 'AddressNumber' => '10' } }

    assert_equal result, expected

    MiniApi::Config.transform_keys_to = :snake_case
  end

  test 'should raise an error if informed option is not valid' do
    MiniApi::Config.transform_keys_to = :test

    hash = { 'first_name' => 'Some random Name', 'address' => { 'address_number' => '10' } }

    assert_raises MiniApi::CaseTransformOptionInvalid do
      MiniApi::CaseTransform.transform(hash)
    end

    MiniApi::Config.transform_keys_to = :snake_case
  end
end
