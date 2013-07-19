class HomeController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
  end

  def support
    if current_user
      @tickets = current_user.tickets
    end
  end

  def economy

  end

end
