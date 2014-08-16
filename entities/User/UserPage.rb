require_relative 'User'

class UserPage
  @users_url = 'http://toster.ru/users/main?page='
  class << self
    attr_accessor :users_url
  end
  def initialize(page_id,user_agent=nil,cookie=nil)
    @page_id = page_id
    @user_agent = user_agent
    @cookie = cookie
    @page = Nokogiri::HTML(open(UserPage.users_url+@page_id.to_s, {'User-Agent' => @user_agent||'', 'Cookie' => @cookie||''}) )
    @users = []
  end


  def get_users
    @page.css('div.left_column div.inner div.users_list_item').each do |el|
      @users << User.new(
          nick      =  el.css('div.login').text,
          rating    =  el.css('div.rating a b').text,
          answers   =  el.css('div.answers_count a b').text,
          questions =  el.css('div.questions_count a b').text,
          name      =  el.css('div.fullname a').text
      )
    end
    @users
  end

end