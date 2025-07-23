class UsersController < ApplicationController
  before_action :load_user, only: [:show]

  # GET /signup
  def new
    @user = User.new
    self.body_class = Settings.body_class.dig(:users, :new_page)
  end

  # POST /signup
  def create
    @user = User.new user_params

    if @user.save
      sign_up_successful
    else
      sign_up_failed
    end
  end

  # GET /users/:id
  def show
    self.body_class = Settings.body_class.dig(:users, :show_page)
  end

  private

  def user_params
    params.require(:user).permit User::USER_PERMIT_PARAMS
  end

  def load_user
    @user = User.find_by(id: params[:id])
    return if @user

    redirect_to root_path, flash: {danger: t(".not_found")}
  end

  def sign_up_successful
    reset_session
    @user&.create_remember_token
    log_in @user
    flash[:success] = t(".success")
    redirect_to @user, status: :see_other
  end

  def sign_up_failed
    self.body_class = Settings.body_class.dig(:users, :new_page)
    flash.now[:danger] = t(".error")
    render :new, status: :unprocessable_entity
  end
end
