class ParseController < ApplicationController

  before_filter :log

  require 'rubygems'
  require 'mechanize'

  attr_accessor :titles, :texts, :errors

  PAGE_ROOT = "http://www.rvb.ru/pushkin/"
  PAGE_URL = "http://www.rvb.ru/pushkin/04index/txtindex.htm"

  def log
    Log.create(text: "#{Time.now}: Params: #{params}")
  end

  def do
  	params[:url] = PAGE_URL

  	a = Mechanize.new { |agent|
      agent.open_timeout   = 2
      agent.read_timeout   = 2
    }

    @errors = []

  	a.get(PAGE_URL) do |page|
  	  page.search('.chapter').each do |ch|
        ch.search('a').each do |link|         

          hyp_link = link['href']
          while ((hyp_link[0] == ".") || (hyp_link[0] == "/")) do hyp_link = hyp_link[1..hyp_link.length-1] end
          if (!Work.exists?(url: hyp_link))
            begin
              a.get(PAGE_ROOT+hyp_link) do |textPage|
                text = ""
                textPage.search('.line').each { |line| text += line.text + "\n" }
                Work.create(url: hyp_link, title: link.text, text: text)
              end
            rescue Exception => ex
              @errors << ex.to_s + "Link : #{hyp_link}. Original link: #{link['href']}."
            end
          end
        end
  	  end
	  end

    @titles = @texts = []
    Work.all.map{ |w| 
      @titles << w.title 
      @texts << w.text
    }
  end

  #Куда ты холоден и cyx!Как слог твой чопорен и бледен!
  #   {
  #   "question" => "Отчизны внемлем призыванье",
  #   "id"       => 6595, # TASK_ID
  #   "level"    => 1,
  # }
  #TOKEN = Token.first.token
  WORD = "%word%"
  def quiz    
    withWORD = false
    searchStr = params['question'].downcase!
    originalQ = searchStr
    if (searchStr.include?(WORD))
      withWORD = true
      searchStr[WORD] = "%"
    end

    @answer = Work.where("text LIKE ?", "%#{params['question']}%")
  end

  def quiz2    
    withWORD = false
    searchStr = params['question'].downcase!
    originalQ = searchStr
    if (searchStr.include?(WORD))
      withWORD = true
      searchStr[WORD] = "%"
    end

    @answer = Work.where("text LIKE ?", "%#{params['question']}%")
    uri = URI("http://pushkin-contest.ror.by/quiz")
    #uri = URI("http://localhost:3000/quiz")
    parameters = {
      answer: @answer.first.title,
      token: Token.first.token,
      task_id:  params[:id]
    }
    Net::HTTP.post_form(uri, parameters)        
    render nothing: true
  end

  def reg
    Token.create(token: params[:token])
    render json: {answer: 'мглою'}
  end
end
