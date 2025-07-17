class MicropostsController < ApplicationController
  def index
    @microposts = Micropost.recent.all
  end
end
