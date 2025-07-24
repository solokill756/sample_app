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

    if user&.authenticate params.dig(:session, :password)
      login_successfull user
    else
      login_failed
    end
  end

  private

  def login_successfull user
    reset_session

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
