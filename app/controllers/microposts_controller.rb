class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user, only: [:destroy]

  # POST /microposts
  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = t(".created")
      redirect_to root_path, status: :see_other
    else
      handle_create_failed
    end
  end

  # DELETE /microposts/:id
  def destroy
    if @micropost.destroy
      flash[:success] = t(".deleted")
    else
      flash[:danger] = t(".error")
    end
    redirect_to request.referer || root_path, status: :see_other
  end

  private

  def micropost_params
    params.require(:micropost).permit Micropost::MICROPOST_PERMIT
  end

  def correct_user
    @micropost = current_user.microposts.find_by(id: params[:id])
    return if @micropost

    flash[:danger] = t(".not_found")
    redirect_to request.referer || root_path, status: :see_other
  end

  def handle_create_failed
    @pagy, @feed_items =
      pagy(
        current_user.microposts.recent
        .includes(Micropost::IMAGE_PRELOAD),
        items: Settings.pagy.items
      )
    flash[:danger] = t(".error")
    self.body_class = Settings.body_class.dig(:static_pages, :home_page)
    render "static_pages/home", status: :unprocessable_entity
  end
end
