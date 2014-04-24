class HomeController < ApplicationController
  before_filter :log
  def hello

  end

  def logs
  	@logs = Log.all
  	# uri = URI("http://obscure-hamlet-3912.herokuapp.com/registration?token=7baced8d61aa5d47e0a7059c1ceaa4ba")
  	# parameters = {
   #    token: "7baced8d61aa5d47e0a7059c1ceaa4ba",
   #    task_id: "Буря %WORD% небо кроет, Вихри снежные крутя"
   #  }
   #  Net::HTTP.post_form(uri, parameters) 
  end

  def list
    @titles = []
    @texts = []
    Work.all.each{ |w| 
      @titles << w.title 
      @texts << w.text
    }
  end

  def log
    Log.create(text: "#{Time.now}: Params: #{params}")
  end
end
