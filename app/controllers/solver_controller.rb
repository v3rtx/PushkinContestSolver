class SolverController < ApplicationController
  before_filter :log

  WORD = "%word%"
  def solve
    searchStr = Unicode::downcase(params['question'])
    wordsQ = searchStr.split()
        
    withWORD = false
    withWORD = true if (searchStr.include?(WORD))

    searchStr.gsub!("#{WORD}", ".*")

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
      @ans = @answer.title.strip
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

  def quiz    
    solve
  end

  def quiz2        
    begin
      solve            
      uri = URI("http://pushkin-contest.ror.by/quiz")
      #uri = URI("http://localhost:3000/quiz")
      parameters = {
        "answer" => @ans,
        "token" => Token.first.token,
        "task_id" => params[:id]
      }
      binding.pry
      Net::HTTP.post_form(uri, parameters)
      render nothing: true
      Log.create("Answer on quiz #{parameters} .")
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

  def log
    Log.create(text: "#{Time.now}: Params: #{params}")
  end
end
