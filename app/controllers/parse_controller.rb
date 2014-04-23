class ParseController < ApplicationController

  require 'rubygems'
  require 'mechanize'

  attr_accessor :titles, :texts, :errors

  PAGE_ROOT = "http://www.rvb.ru/pushkin"
  PAGE_URL = "http://www.rvb.ru/pushkin/04index/txtindex.htm"

  def do
  	params[:url] = PAGE_URL

  	a = Mechanize.new { |agent|
      agent.open_timeout   = 1
      agent.read_timeout   = 1
    }

  	@titles = []
  	@texts = []
    @errors = []

  	a.get(PAGE_URL) do |page|
  	  page.search('.chapter').each do |ch|
        ch.search('a').each do |link|
          @titles << link.text 

          hyp_link = link['href']
          link_start = hyp_link.index("/")
          if (link_start != nil)
            hyp_link = hyp_link.slice(link_start, hyp_link.length - link_start )
          else
            hyp_link = "/" + hyp_link
          end

          begin
            a.get(PAGE_ROOT+hyp_link) do |textPage|
              text = ""
              textPage.search('.line').each { |line| text += line.text }
              @texts << text
            end
          rescue Exception => ex
            @errors << ex.to_s + "Link : #{hyp_link}. Original link: #{link['href']}."
          end
        end
  	  end
	  end
  end
end
