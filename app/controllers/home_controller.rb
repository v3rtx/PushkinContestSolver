class HomeController < ApplicationController
  def hello

  end

  def logs
  	@logs = Log.all.sort_by { |l| l.text }
  end

  def list
    @titles = []
    @texts = []
    Work.all.each{ |w| 
      @titles << w.title 
      @texts << w.text
    }
  end
end
