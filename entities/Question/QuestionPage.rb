# Representation of page with question, may have some other entities
require_relative 'Question'
require_relative 'Answer'
require_relative 'AnswerComment'

class QuestionPage
  @questions_url = 'http://toster.ru/q/'
  class << self
    attr_accessor :questions_url
  end

  def initialize(page_id, user_agent=nil, cookie=nil)
    @page_id = page_id
    @user_agent = user_agent
    @cookie = cookie
    @page = Nokogiri::HTML(open(QuestionPage.questions_url+@page_id.to_s, {'User-Agent' => @user_agent||'', 'Cookie' => @cookie||''}))

  end

  def get_question
    tags=[]
    @page.css('div.question_show div.info div.tags div.tag a[itemprop=articleSection]').each { |t| tags<<t.text }
    Question.new(
        title = @page.css('span[itemprop="name"]').text,
        descr = @page.css('div[itemprop="articleBody"]').text,
        likes = @page.css('div.question_interest_link_float_container span').text.strip,
        created_at = @page.css('div.date').attr('content'),
        user = @page.css('a[itemprop="name"]').text,
        views = @page.css('div.views')[0].text,
        comments_count = @page.css('a.add_clarification_link').text.strip.match(/[0-9]+/) || 0,
        tags = tags
    )
  end

  def get_answers
    answers = []


    @page.css('li.answers_list_item').each do |answer|
      answers << Answer.new(
          answer.css('div.answer__body div.answer__header div.answer__meta a').text,
          answer.css('div.answer__body div.answer__text').text,
          answer.css('div.answer__body div.answer__feedback a strong').text.strip.match(/[0-9]+/) || 0,
          get_comments(answer),
          'creata',
          'acc'
      )
    end
    answers
  end

  private
  def get_comments(answer)
    answers_comments = []
    answer.css('div.answer__body div.answer__feedback div div ul li').each do |c|
      answers_comments<<
          AnswerComment.new(
              c.css('div.comment__body div.comment__header div.comment__meta a.comment__username').text,
              c.css('div.comment__body div.comment__text').text,
              'created_at'
          )
    end
    answers_comments
  end
end