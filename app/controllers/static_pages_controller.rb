class StaticPagesController < ApplicationController
  # GET / home
  def home
    self.body_class = Settings.body_class.dig(:static_pages, :home_page)
    @micropost = current_user&.microposts&.build if logged_in?
    return unless logged_in?

    microposts = current_user.feed
    @pagy, @feed_items = pagy(microposts, items: Settings.pagy.items)
  end

  # GET / contact
  def contact; end

  # GET / help
  def help; end
end
