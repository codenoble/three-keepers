module AuthenticationHelpers
  # for integration tests
  def login_as(username)
    visit root_path
    fill_in 'username', with: username
    fill_in 'password', with: 'bogus password'
    click_button 'Login'
  end
end
