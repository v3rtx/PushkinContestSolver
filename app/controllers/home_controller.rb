class HomeController < ApplicationController
  def hello

  end

  def logs
  	@logs = Log.all
  end
end
