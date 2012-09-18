class AdminController < ApplicationController
  before_filter :authenticate

  def authenticate
    authenticate_or_request_with_http_basic('Administration') do |username, password|
      session[:admin] = true
      username == 'admin1' && password == 'password'
    end
  end
end