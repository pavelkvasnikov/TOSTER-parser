class QuestionPageList
  @pages_url = 'http://toster.ru/my/feed_latest?page='
  class << self
    attr_accessor :pages_url
  end

  def self.get_questions_ids(user_agent=nil, cookie=nil)
    urls_list = []
    1.upto(Float::INFINITY) do |page_number|
      begin
        page = Nokogiri::HTML(open("http://toster.ru/my/feed_latest?page=#{page_number}", {'User-Agent' => user_agent||'', 'Cookie' => cookie||''}))
        page.css('div.info div.title a').each { |t| urls_list<< t.attr('href')[/[0-9]+/] }
        print "parsing paginator page #{page_number}  of ~1000      \r"
      rescue OpenURI::HTTPError => exception
        if exception.message=='404 Not Found'
          return urls_list
        else
          raise OpenURI::HTTPError.new(exception, nil)
        end
      end
    end
  end
end

