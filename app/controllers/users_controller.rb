class UsersController < ApplicationController
  before_action :load_user,
                only: %i(show edit update destroy following followers)
  before_action :logged_in_user,
                only: %i(show edit update destroy following followers)
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
      send_activation_email
    else
      sign_up_failed
    end
  end

  # GET /users/:id
  def show
    self.body_class = Settings.body_class.dig(:users, :show_page)
    @page, @microposts =
      pagy(
        @user.microposts.recent
        &.includes(Micropost::IMAGE_PRELOAD),
        items: Settings.pagy.items
      )
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

  # GET /users/:id/following
  def following
    @title = t(".following")
    @pagy, @users = pagy(@user.following, items: Settings.pagy.items)
    self.body_class = Settings.body_class.dig(:users, :follow_page)
    render :show_follow, status: :ok
  end

  def followers
    @title = t(".followers")
    self.body_class = Settings.body_class.dig(:users, :follow_page)
    @pagy, @users = pagy(@user.followers, items: Settings.pagy.items)
    render :show_follow, status: :ok
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

  def sign_up_failed
    self.body_class = Settings.body_class.dig(:users, :new_page)
    flash.now[:danger] = t(".error")
    render :new, status: :unprocessable_entity
  end

  def correct_user
    return if current_user?(@user) || current_user.admin?

    flash[:danger] = t(".not_correct_user")
    redirect_to root_path, status: :see_other
  end

  def send_activation_email
    @user.send_activation_email
    flash[:info] = t(".check_email")
    redirect_to root_path, status: :see_other
  rescue StandardError => e
    Rails.logger.error "Failed to send activation email: #{e.message}"
    flash[:danger] = t(".email_error")
    redirect_to root_path, status: :see_other
  end
end
