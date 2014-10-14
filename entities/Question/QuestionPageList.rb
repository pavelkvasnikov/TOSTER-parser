class QuestionPageList
  @pages_url = 'http://toster.ru/my/feed_latest?page='
  class << self
    attr_accessor :pages_url
  end

  def self.get_questions_ids(user_agent=nil, cookie=nil)
    page = Nokogiri::HTML(open("http://toster.ru", {'User-Agent' => user_agent||'', 'Cookie' => cookie||''}))
    (1..page.css('body > div > div.content.with_sidebar > div.main_content > div.left_column > div > div.questions_list.shortcuts_items > div:nth-child(1) > div.info > div.title > a')[0].attr('href')[/[0-9]+/].to_i).to_a

  end
end

