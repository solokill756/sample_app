class PasswordResetsController < ApplicationController
  before_action :load_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  # GET /password_resets/new
  def new
    self.body_class = Settings.body_class.dig(:password_resets, :new_page)
  end

  # GET /password_resets/:id/edit
  def edit
    self.body_class = Settings.body_class.dig(:password_resets, :edit_page)
  end

  # POST /password_resets
  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      handle_password_reset_request
    else
      handle_email_not_found
    end
  end

  # PATCH/PUT /password_resets/:id
  def update
    if password_empty?
      handle_empty_password
    elsif @user.update(user_params)
      handle_successful_password_update
    else
      handle_failed_password_update
    end
  end

  private

  def load_user
    @user = User.find_by email: params[:email].downcase
    return if @user

    flash[:danger] = t(".user_not_found")
    redirect_to root_url, status: :see_other
  end

  def valid_user
    return if @user&.activated? && @user.authenticated?(:reset,
                                                        params[:id])

    flash[:danger] = t(".invalid_user")
    redirect_to root_url, status: :see_other
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t(".password_reset_expired")
    redirect_to new_password_reset_url, status: :see_other
  end

  def handle_password_reset_request
    @user.create_reset_digest
    @user.send_password_reset_email
    flash[:info] = t(".email_sent")
    redirect_to root_url, status: :see_other
  end

  def handle_email_not_found
    self.body_class = Settings.body_class.dig(:password_resets, :new_page)
    flash.now[:danger] = t(".email_not_found")
    render :new, status: :unprocessable_entity
  end

  def password_empty?
    user_params[:password].empty?
  end

  def handle_empty_password
    @user.errors.add(:password, :blank)
    render :edit, status: :unprocessable_entity
  end

  def handle_successful_password_update
    @user.update(reset_digest: nil)
    UserMailer.password_reset_success(@user , @user.password).deliver_now
    flash[:success] = t(".password_reset_success")
    redirect_to root_url, status: :see_other
  end

  def handle_failed_password_update
    self.body_class = Settings.body_class.dig(:password_resets, :edit_page)
    flash.now[:danger] = t(".password_reset_failure")
    render :edit, status: :unprocessable_entity
  end
end
