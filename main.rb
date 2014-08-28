require 'nokogiri'
require 'sequel'
require 'open-uri'
require_relative 'database'
require_relative 'entities/Question/QuestionPage'
require_relative 'entities/Question/QuestionPageList'
class String
  # Remember that by default 'Time.new' uses current system time zone with GMT
  # if you need UTC, convert it explicit with .utc
  def parse_date
    # Full date time format <DD.MM.YYYY, в hh:mm>, 'в' is russian letter
    if self.match(/[0-9][0-9]\.[0-9][0-9]\.[0-9][0-9][0-9][0-9],.+/)
      return Time.new(self[6..9],self[3..4],self[0..1],self[-5..-4],self[-2..-1])
    end
    # Partial date format <DD.MM, в hh:mm>, like previous but without year, 'в' is russian letter
    if self.match(/[0-9][0-9]\.[0-9][0-9],.+/)
      return Time.new(Time.now.year,  self[3..4], self[0..1],self[-5..-4],self[-2..-1])
    end
    # Question date mix from content attribute and pure text
    if self.match(/[0-9][0-9][0-9][0-9].+/)
      return Time.new(self[0..3],self[5..6],self[8..9], self[11..12], self[14..15])
    end
    # Some hours ago
    if self.match(/[0-9]+ час.+/)
      return Time.now - (60*60*self[/[0-9]+/].to_i)
    end
    # Some minutes ago
    if self.match(/[0-9]+ мин.+/)
      return Time.now - (60*self[/[0-9]+/].to_i)
    end
    # An hour ago
    if self=='час назад'
      return Time.now - 60*60
    end
    # A minute ago
    if self=='минуту назад'#
      return Time.now - 60
    end
    if self=='вчера'
      return Time.now - 60*60*24
    end

  end
end

 user_agent = 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36'
 cookie = 'toster_sid=2uk03e20bfupr4e3ce0355mqj5; _ga=GA1.2.1678308696.1403085862; _dc=1; _ym_visorc_24049246=b'
# urls = QuestionPageList.get_questions_ids(user_agent,cookie)


qq = QuestionPage.new(95401,user_agent,cookie).get_question.user
  puts qq.nick
  puts qq.rating


exit 0
question,answers = QuestionPage.new(95401,user_agent,cookie).get_all

puts 'QUESTION DATE = '+question.created_at.to_s

puts

answers.each do |answer|
  puts '    ANSWER DATE = '+answer.created_at.to_s
  puts
  answer.comments.each do |comment|
       puts '        COMMENT DATE = ' + comment.created_at.to_s
       puts
    end
end


exit 0
page = Nokogiri::HTML(open('http://toster.ru/my/feed_latest?page=16', {'User-Agent' => user_agent||'', 'Cookie' => cookie||''}))

# page = Nokogiri::HTML(open('http://toster.ru/q/118059', {'User-Agent' => user_agent||'', 'Cookie' => cookie||''}) )
# tags =[]



