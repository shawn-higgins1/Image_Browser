# frozen_string_literal: true

require 'test_helper'

class MainControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get main_home_url
    assert_response :success
  end

  test "should get help" do
    get main_help_url
    assert_response :success
  end
end
