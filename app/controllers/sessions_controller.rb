class SessionsController < ApplicationController
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
    user = User.find_by email: params.dig(:session, :email)&.downcase

    if user&.authenticate(params.dig(:session, :password))
      login_successful user
    else
      login_failed
    end
  end

  private

  def login_successful user
    reset_session
    if params.dig(:session,
                  :remember_me) == Settings.models.dig(:user, :remember_me)
      remember_cookies(user)
    else
      user&.create_remember_token
    end
    log_in user
    flash[:success] = t(".success")
    redirect_to user, status: :see_other
  end

  def login_failed
    self.body_class = Settings.body_class.dig(:sessions, :new_page)
    flash.now[:danger] = t(".error")
    render :new, status: :unprocessable_entity
  end
end
