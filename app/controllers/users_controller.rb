class UsersController < ApplicationController
  before_action :load_user, only: %i(show edit update destroy)
  before_action :logged_in_user, only: %i(show edit update destroy)
  before_action :correct_user, only: %i(show edit update)
  before_action :admin_user, only: :destroy

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

  # GET /users/:id/edit
  def edit
    self.body_class = Settings.body_class.dig(:users, :edit_page)
  end

  # PATCH /users/:id
  def update
    if @user.update(user_params)
      flash[:success] = t(".success")
      redirect_to @user, status: :see_other
    else
      self.body_class = Settings.body_class.dig(:users, :edit_page)
      flash[:danger] = t(".error")
      render :edit, status: :unprocessable_entity
    end
  end

  # GET /users
  def index
    @pagy, @users = pagy(User.newest, items: Settings.pagy.items)
    self.body_class = Settings.body_class.dig(:users, :index_page)
  end

  # DELETE /users/:id
  def destroy
    if @user.destroy
      flash[:success] = t(".success", name: @user.name)
    else
      flash.now[:danger] = t(".error")
    end
    redirect_to users_path, status: :see_other
  end

  private

  def admin_user
    return if current_user&.admin?

    flash[:danger] = t(".not_admin")
    redirect_to root_path, status: :see_other
  end

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
    flash[:success] = t(".success", name: @user.name)
    redirect_to @user, status: :see_other
  end

  def sign_up_failed
    self.body_class = Settings.body_class.dig(:users, :new_page)
    flash.now[:danger] = t(".error")
    render :new, status: :unprocessable_entity
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t(".please_login")
    redirect_to login_path, status: :see_other
  end

  def correct_user
    return if current_user?(@user) || current_user.admin?

    flash[:danger] = t(".not_correct_user")
    redirect_to root_path, status: :see_other
  end
end
