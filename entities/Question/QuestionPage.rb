# Representation of page with question, may have some other entities
require_relative 'Question'
require_relative 'Answer'
require_relative 'Comment'

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
    comments = []
    @page.css('div.question_show div.info div.tags div.tag a[itemprop=articleSection]').each { |t| tags<<t.text }
    Question.new(
        title = @page.css('span[itemprop="name"]').text,
        descr = @page.css('div[itemprop="articleBody"]').text,
        likes = @page.css('div.question_interest_link_float_container span').text.strip,
        created_at = get_question_date,
        user = @page.css('a[itemprop="name"]').text,
        views = @page.css('div.views')[0].text,
        comments_count = @page.css('a.add_clarification_link').text.strip.match(/[0-9]+/) || 0,
        tags = tags,
        comments = comments
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
          answer.css('div.answer__controls a.date').text.strip.parse_date,
          answer.css('div.answer__body div.answer__header div.answer__meta span.answer__approve span.answer__solution').text || ''
      )
    end
    answers
  end

  def get_all

    question = get_question,answers= get_answers


  end

  private
  def get_comments(answer)
    answers_comments = []
    answer.css('div.answer__body div.answer__feedback div div ul li').each do |c|
      answers_comments<<
          Comment.new(
              c.css('div.comment__body div.comment__header div.comment__meta a.comment__username').text,
              c.css('div.comment__body div.comment__text').text,
              c.css('div.comment__body div.comment__header div.comment__controls a.date').text.strip.parse_date,
              type = 'answer_comment'
          )
    end
    answers_comments
  end
  def get_question_date
    date = @page.css('div.date')[0]['content'][0..9]+' '+@page.css('div.date')[0].text[-5..-1]
    date.parse_date
  end
end
