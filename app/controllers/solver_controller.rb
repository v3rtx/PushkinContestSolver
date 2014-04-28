class SolverController < ApplicationController
  #before_filter :log

  WORD = "%word%"
  RU_STR = /[а-яА-Я0-9]+/

  def solveQuiz    
    searchStrOrig = params['question']
    wordsQOrig = searchStrOrig.gsub(/\s+/," ").strip.split()
    queryStr = "text LIKE "
    (0..wordsQOrig.count-1).each{ |i|
      queryStr += "'%#{wordsQOrig[i]}%'"
      queryStr += " OR text LIKE " if (i != wordsQOrig.count-1)
    }
    if ((params[:level] == 5) || (params[:level] == "5"))
      (0..wordsQOrig.count-1).each{ |i|
        begin
          wordsQ = searchStrOrig.split()
          wordsQ[i].gsub!(/\S+/, WORD)
          @searchStr = Unicode::downcase(wordsQ.join(" "))
          solve
        rescue Exception => e
          #Log.create(text: "#{Time.now}: Not found. Search string: #{@searchStr}")
        end
        # if we are here than seems like we got something
        if ( @ans != nil)          
          #Log.create(text: "#{Time.now}: Found. Search string: #{@searchStr}")
          @ans += ",#{wordsQOrig[i][RU_STR]}"
          return
        end
      }
    else
      @searchStr = Unicode::downcase(searchStrOrig)
      solve
    end

    if (@ans.match(/.*«.*».*/) != nil)
      @ans = @ans.scan(/.*«(.*)».*/)
    end
  end

  def solve              
    wordsQ = @searchStr.split()

    withWORD = false
    withWORD = true if (@searchStr.include?(WORD))

    @searchStr.gsub!("#{WORD}", "\\S+")
    @searchStr = "\\W{1}" + @searchStr + "\\W{1}"
    ItemsProvider::ALL_WORKS.map{|w| 
      text = " "+w.text+" "
      if (text[/.*#{@searchStr}.*/] != nil) 
        @answer = w
        break
      elsif (text.gsub("\n"," ")[/.*#{@searchStr}.*/] != nil) 
        @answer = w
        @answer.text.gsub!("\n"," ")
        break
      end
    }

    wordsA = (" "+@answer.text + " ").scan(/.*(#{@searchStr}).*/)[0][0].split().map {|a| a[RU_STR]  }

    if (!withWORD)      
      @ans = @answer.title.strip
    else
      @ans = ""
      for i in (0..wordsQ.size-1)
        if (wordsQ[i].match(/.*#{WORD}.*/) != nil)
          if (@ans.length > 0)
            @ans += ",#{wordsA[i]}" 
          else
            @ans += wordsA[i]
          end
        end
      end
    end
  end

  def quiz    
    solveQuiz
  end

  def quiz2        
    begin
      solveQuiz            
      uri = URI("http://pushkin-contest.ror.by/quiz")
      parameters = {
        "answer" => @ans,
        "token" => Token.first.token,
        "task_id" => params[:id]
      }
      Net::HTTP.post_form(uri, parameters)
      render nothing: true
      Log.create(text: "#{Time.now}: Task: #{params}; Answer on quiz #{parameters}.")
    rescue Exception => e
      Log.create(text: "#{Time.now}: #{e} #{e.backtrace}")
    end
  end

  def reg
    Token.create(token: params[:token])
    begin
      solve      
    rescue Exception => e
      Log.create(text: e)
    end
    render json: {answer: @ans}
  end

  def log
    Log.create(text: "#{Time.now}: Params: #{params}")
  end
end
