require 'nokogiri'
require 'sequel'
require 'open-uri'
require_relative 'database'


user_agent = 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36'
cookie = 'toster_sid=ae5ej6ohrfnt4s06ojrt5r5ng0; _dc=1; _ga=GA1.2.1678308696.1403085862; _ym_visorc_24049246=b'

# page = Nokogiri::HTML(open('http://toster.ru/q/118059', {'User-Agent' => user_agent||'', 'Cookie' => cookie||''}) )
# tags =[]

# puts tags
# exit 0

class Question
  attr_reader :title,:descr,:likes,:created_at,:user,:views,:comments_count, :tags
  def initialize(title,descr,likes,created_at,user,views,comments_count,tags)
    @title=title
    @descr=descr
    @likes=likes
    @created_at=created_at
    @user= user
    @views= views
    @comments_count= comments_count
    @tags = tags
  end
end

class Answer
  def initialize
    raise 'Not implemented'
  end
end
class QuestionPage
  @questions_url = 'http://toster.ru/q/'
  class << self
    attr_accessor :questions_url
  end

  def initialize(page_id,user_agent=nil,cookie=nil)
    @page_id = page_id
    @user_agent = user_agent
    @cookie = cookie
    @page = Nokogiri::HTML(open(QuestionPage.questions_url+@page_id.to_s, {'User-Agent' => @user_agent||'', 'Cookie' => @cookie||''}) )

  end
  def get_question
       tags=[]
       @page.css('div.question_show div.info div.tags div.tag a[itemprop=articleSection]').each{|t| tags<<t.text}
       Question.new(
           title= @page.css('span[itemprop="name"]').text,
           descr= @page.css('div[itemprop="articleBody"]').text,
           likes= @page.css('div.question_interest_link_float_container span').text.strip,
           created_at= @page.css('div.date').attr('content'),
           user= @page.css('a[itemprop="name"]').text,
           views= @page.css('div.views')[0].text,
           comments_count= @page.css('a.add_clarification_link').text.strip.match(/[0-9]+/) || 0,
           tags = tags
       )
  end

end

answers = QuestionPage.new(118059,user_agent,cookie)
puts answers.get_question.tags


