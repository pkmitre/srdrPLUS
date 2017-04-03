require 'test_helper'

class RegistrationFlowTest < Capybara::Rails::TestCase
  include ActiveJob::TestHelper

  def setup
  end

  test 'submitting a registration form should send out an email' do
    sign_up_user

    mail = ActionMailer::Base.deliveries.last

    assert_equal 'user@brand.new.com', mail['to'].to_s
    assert_equal 'Confirmation instructions', mail.subject
  end

  test 'new user should have confirmed_at set to nil, profile set to nil' do
    sign_up_user

    last_user = User.last

    assert_nil last_user.confirmed_at
    assert_nil last_user.profile
  end

  test 'confirm new user should make user confirmed' do
    sign_up_user

    last_user = User.last

    assert_nil last_user.confirmed_at
    visit user_confirmation_path(confirmation_token: last_user.confirmation_token)
    assert_not_nil last_user.reload.confirmed_at
  end

  test 'confirming email should create profile' do
    sign_up_user

    last_user = User.last

    assert_nil last_user.profile
    visit user_confirmation_path(confirmation_token: last_user.confirmation_token)
    assert_not_nil last_user.reload.profile
  end

  private

  def sign_up_user
    perform_enqueued_jobs do
      visit new_user_registration_path

      fill_in 'Email', with: 'user@brand.new.com'
      fill_in 'Password', with: 'passw0rd', match: :prefer_exact
      fill_in 'Password confirmation', with: 'passw0rd', match: :prefer_exact

      click_on 'Sign up'
    end
  end
end