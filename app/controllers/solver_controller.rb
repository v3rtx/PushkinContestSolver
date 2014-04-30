class SolverController < ApplicationController
  before_filter :log

  WORD = "%word%"
  NON_WORD_CH = /[:;.,?!-+=`~]+/

  def solveQuiz    
    searchStrOrig = params['question']
    searchStrOrig.gsub!(/\s+/, " ")
    wordsQOrig = searchStrOrig.strip.split()   
    ids = []
    wordsQOrig.each { |w|
      tmp = ItemsProvider::REDIS[Unicode::downcase(w.gsub(NON_WORD_CH, ""))]
      if (tmp != nil)
        ids << tmp.uniq
      end
    }
    ids.flatten!
    if (wordsQOrig.count > 2)
      pure_ids = ids.group_by{|id| id}.map{|id, array| [id,array.count]}.sort_by{|id,count| count}.reverse
      pure_ids.map!{ |id, count| id }
    end

    searchStrings = []
    (0..wordsQOrig.count-1).each{ |i|
      wordsQ = searchStrOrig.split()
      wordsQ[i].gsub!(/\S+/, WORD)
      searchStrings << Unicode::downcase(wordsQ.join(" "))
    }  

    #==========================
    if ((params[:level] == 5) || (params[:level] == "5"))   
      pure_ids.each{ |id|    
        work = Work.find(id)
        (0..searchStrings.length).each{ |i|
          begin       
            solve([work], searchStrings[i])
            # if we are here than seems like we got something

            if ( @ans != nil)  
              @ans += ",#{wordsQOrig[i].gsub(NON_WORD_CH, "")}"
              return
            end  
          rescue Exception => e
          end
        }
      }
    else
      solve(Work.find(pure_ids), Unicode::downcase(searchStrOrig))
    end
    #==========================
    if (@ans.match(/.*«.*».*/) != nil)
      @ans = @ans.scan(/.*«(.*)».*/)
    end
  end

  def solve(works, searchStr)
    wordsQ = searchStr.split()

    withWORD = false
    withWORD = true if (searchStr.include?(WORD))

    searchStr.gsub!("#{WORD}", "\\S+")
    searchStr = "\\W{1}" + searchStr + "\\W{1}"
    works.map{|w| 
      text = " "+w.text+" "
      if (text[/.*#{searchStr}.*/] != nil) 
        @answer = w
        break
      elsif (text.gsub("\n"," ")[/.*#{searchStr}.*/] != nil) 
        @answer = w
        @answer.text.gsub!("\n"," ")
        break
      end
    }

    wordsA = (" "+@answer.text + " ").scan(/.*(#{searchStr}).*/)[0][0].split().map {|a| a.gsub(NON_WORD_CH, "")  }

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
      Log.create(text: "#{Time.now}: Answer on quiz #{parameters}.")
    rescue Exception => e
      Log.create(text: "#{Time.now}: #{e} #{e.backtrace} #{params}")
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

  def init
      Work.all.each { |work|
      lines = work.text.split("\n")
      lines.each{ |l| 
        words = l.split()
        @errors = ""
        words.each{ |w| 
          pure_word = w.gsub(NON_WORD_CH,"")
          begin
            if (pure_word != nil)
              if (ItemsProvider::REDIS[pure_word] == nil)
                ItemsProvider::REDIS[pure_word] = []
              end
              ItemsProvider::REDIS[pure_word] << work.id
            end
          rescue Exception => e
            @errors += "#{e}: #{w}\n"
          end
        }
      }
    }
    
    Work.all.each{ |w| 
      ItemsProvider::REDIS[w.id] = w
    }
  end

  def log
    Log.create(text: "#{Time.now}: Params: #{params}")
  end
end
