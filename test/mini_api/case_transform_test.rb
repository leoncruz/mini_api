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
    hash = { 'first_name' => 'Some random Name', 'address' => { 'address_number' => '10' } }

    result = MiniApi::CaseTransform.transform(hash, :camel_lower)

    expected = { 'firstName' => 'Some random Name', 'address' => { 'addressNumber' => '10' } }

    assert_equal result, expected
  end

  test 'should transform keys to CamelCase when informed' do
    hash = { 'first_name' => 'Some random Name', 'address' => { 'address_number' => '10' } }

    result = MiniApi::CaseTransform.transform(hash, :camel_case)

    expected = { 'FirstName' => 'Some random Name', 'Address' => { 'AddressNumber' => '10' } }

    assert_equal result, expected
  end

  test 'should raise an error if informed option is not valid' do
    hash = { 'first_name' => 'Some random Name', 'address' => { 'address_number' => '10' } }

    assert_raises MiniApi::CaseTransformOptionInvalid do
      MiniApi::CaseTransform.transform(hash, :test)
    end
  end
end
