class AccountActivationsController < ApplicationController
  before_action :load_user, only: [:edit]
  before_action :validate_activation, only: [:edit]

  # GET /account_activations/:id/edit
  def edit
    @user.activate
    @user.create_remember_token
    log_in @user
    flash[:success] = t(".success")
    redirect_to @user, status: :see_other
  end

  private

  def validate_activation
    return if !@user.activated? && @user.authenticated?(:activation,
                                                        params[:id])

    flash[:danger] = t(".invalid_activation_link")
    redirect_to root_url
  end

  def load_user
    @user = User.find_by(email: params[:email])
    return if @user

    flash[:danger] = t(".user_not_found")
    redirect_to root_url
  end
end
