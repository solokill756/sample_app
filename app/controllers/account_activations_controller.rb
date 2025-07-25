class AccountActivationsController < ApplicationController
  before_action :load_user, only: [:edit]

  # GET /account_activations/:id/edit
  def edit
    if @user && !@user.activated? && @user.authenticated?(:activation, params[:id])
      user_successfully_activated
    else
      user_activated_failure
    end
  end

  private

  def user_successfully_activated
    @user.activate
    @user.create_remember_token
    log_in @user
    flash[:success] = t(".success")
    redirect_to @user
  end

  def user_activated_failure
    flash[:danger] = t(".error")
    redirect_to root_url
  end

  def load_user
    @user = User.find_by(email: params[:email])
  end
end
