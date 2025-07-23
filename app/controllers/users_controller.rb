class UsersController < ApplicationController
  before_action :load_user, only: [:show]

  # GET /signup
  def new
    @body_class = Settings.body_class.user_new_page
    @user = User.new
  end

  # POST /signup
  def create
    @user = User.new user_params
    if @user.save
      flash[:success] = t(".success", name: @user.name)
      redirect_to @user
    else
      @body_class = Settings.body_class.user_new_page
      flash.now[:danger] = t(".error")
      render :new, status: :unprocessable_entity
    end
  end

  # GET /users/:id
  def show
    @body_class = Settings.body_class.user_show_page
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
end
