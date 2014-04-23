class ParseController < ApplicationController

  require 'rubygems'
  require 'mechanize'

  attr_accessor :names, :texts

  PAGE_ROOT = "http://www.klassika.ru"
  PAGE_URL = "http://www.klassika.ru/stihi/pushkin/"

  def do
  	params[:url] = PAGE_URL

  	a = Mechanize.new 

  	@names = []
  	@texts = []
  	a.get(PAGE_URL) do |page|
  	  page.search('li').each do |list_item|
  	    @names << list_item.text
        a.get(PAGE_ROOT+list_item.search('a').first['href']) do |textPage|
          @texts << textPage.search('pre').text
        end
  	  end
	  end
  end
end
