class HomeController < ApplicationController

  def index
    @apikey = ENV["OS_APIKEY"]
    render 'index'
  end

  def preview_proxy

  end

end
