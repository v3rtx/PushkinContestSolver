class ParseController < ApplicationController

  require 'rubygems'
  require 'mechanize'
  require 'unicode'

  PAGE_ROOT = "http://www.rvb.ru/pushkin/"
  PAGE_URL = "http://www.rvb.ru/pushkin/04index/txtindex.htm"

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

  def to_lines
    ItemsProvider::ALL_WORKS.each { |w|
      lines = w.text.split("\n")
      lines.each{ |l| 
        Line.create(work_id: w.id, line_text: l.gsub(/\s+/, " "))
      }
    }
  end
end
