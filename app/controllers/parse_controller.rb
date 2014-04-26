class ParseController < ApplicationController

  before_filter :log

  require 'rubygems'
  require 'mechanize'
  require 'unicode'

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
                Work.create(url: hyp_link, title: link.content.gsub(/—.*/,""), text: Unicode::downcase(text))
              end
            rescue Exception => ex
              @errors << ex.to_s + "Link : #{hyp_link}. Original link: #{link['href']}."
            end
          end
        end
  	  end
	  end

    @titles = []
    @texts = []
    Work.all.each{ |w| 
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
  def quiz    
    solve
  end

  WORD = "%word%"
  def solve
    withWORD = false
    question = Unicode::downcase(params['question']);
    searchStr = question
    wordsQ = searchStr.split()
    
    
    withWORD = true if (searchStr.include?(WORD))

    searchStr = searchStr.gsub!(/#{WORD}/, ".*")

    Work.all.map{|w| 
      if (w.text[/.*#{searchStr}.*/] != nil) 
        @answer = w
        break
      elsif (w.text.gsub("\n"," ")[/.*#{searchStr}.*/] != nil) 
        @answer = w
        @answer.text.gsub!("\n"," ")
        break
      end
    }

    wordsA = @answer.text.scan(/.*(#{searchStr}).*/)[0][0].split()

    if (!withWORD)      
      @ans = @answer.title
    else
      @ans = ""
      for i in (0..wordsQ.size)
        if (wordsQ[i] == WORD)
          if (@ans.length > 0)
            @ans += ", #{wordsA[i]}" 
          else
            @ans += wordsA[i]
          end
        end
      end
    end
  end

  def quiz2        
    begin
      solve            
      uri = URI("http://pushkin-contest.ror.by/quiz")
      # => uri = URI("http://localhost:3000/quiz")
      parameters = {
        "answer" => @ans,
        "token" => Token.first.token,
        "task_id" => params[:id]
      }
      Net::HTTP.post_form(uri, parameters)
      render nothing: true
      Log.create("Answer on quiz #{parameters}.")
    rescue Exception => e
      Log.create(text: e.message)
    end
  end

  def reg
    Token.create(token: params[:token])
    begin
      solve      
    rescue Exception => e
      Log.create(text: e.message)
    end
    render json: {answer: @ans}
  end
end
