require 'rubygems'
require 'curb'
require 'json'
require 'nokogiri'

class Parsing 

  URL = "http://unibelus.by"
  URL_PARS = '/ru/news.html'
  URL_ONE_PAGE = '/ru/news.html?p='
  PAGES_NAV = 'div.pages-nav > a'
  LINK_NEWS = 'div.inner > div.text > div.news-block > a.titl'
  DATE = '//*[@id="container"]/div/div[2]/div[2]/div/div[2]/span'
  TITLE = '//*[@id="container"]/div/div[2]/div[2]/div/div[2]/h1'
  IMAGE = '//*[@id="container"]/div/div[2]/div[2]/div/div[2]/div[1]/img'
  TEXT = '//*[@id="container"]/div/div[2]/div[2]/div/div[2]/p'

  def initialize
    @array_of_url = []
    @array_of_news = []
    @array_of_links = []
    @count = -1
    super()
  end

  def start
    count
    array_url
    details
    write_to_json
  end

  def pars_page(url, link)
    http = Curl.get(url + link)
    @page = Nokogiri::HTML(http.body_str)  
  end

  def count
    pars_page(URL, URL_PARS)
    @page.css(PAGES_NAV).each do |i|
      @count += 1
      links = "#{URL_ONE_PAGE}#{@count}"
      @array_of_links << links
    end    
  end

  def array_url
    @array_of_links.each do |l|
      begin
        pars_page(URL, l)
        @page.css(LINK_NEWS).each do |url|
          @array_of_url << url['href']
        end    
      rescue
        next
      end
    end
  end

  def details
    @array_of_url.each do |link|
      begin
        pars_page(URL, link)
        date = @page.xpath(DATE).text
        title = @page.xpath(TITLE).text
        if @page.xpath(IMAGE).empty?
          image = ''
        else
          image = @page.xpath(IMAGE)[0]['src'] 
        end
        text = @page.xpath(TEXT).text
        @array_of_news << [date: date, title: title, image_url: image, text: text]
      rescue
        next
      end
    end
  end

  def write_to_json
    File.open("news.json", "w") do |file|
      file.puts JSON.pretty_generate(@array_of_news)
    end
  end
  
end

ins = Parsing.new
ins.start


