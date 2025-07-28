class SessionsController < ApplicationController
  before_action :handle_login_validation, only: :create
  before_action :login_successful_validation, only: :login_successful

  # GET /login
  def new
    self.body_class = Settings.body_class.dig(:sessions, :new_page)
  end

  # DELETE /logout
  def destroy
    log_out
    flash[:success] = t(".success")
    redirect_to root_url, status: :see_other
  end

  # POST /login
  def create
    login_successful
  end

  private

  def login_successful
    forwarding_url = session[:forwarding_url]
    reset_session
    handle_remember_me_preference
    log_in @user
    flash[:success] = t(".success")
    redirect_to forwarding_url || @user, status: :see_other
  end

  def handle_remember_me_preference
    if params.dig(:session,
                  :remember_me) == Settings.models.dig(:user, :remember_me)
      remember_cookies(@user)
    else
      @user&.create_remember_token
    end
  end

  def handle_login_validation
    @user = User.find_by email: params.dig(:session, :email)&.downcase
    return if @user&.authenticate(params.dig(:session, :password))

    flash.now[:danger] = t(".error")
    self.body_class = Settings.body_class.dig(:sessions, :new_page)
    render :new, status: :unprocessable_entity
  end

  def login_successful_validation
    return if @user.activated?

    flash[:danger] = t(".not_activated")
    redirect_to root_path, status: :see_other
  end
end
