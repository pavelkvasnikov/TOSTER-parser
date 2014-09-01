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
      return Time.new(self[6..9], self[3..4], self[0..1], self[-5..-4], self[-2..-1])
    end
    # Partial date format <DD.MM, в hh:mm>, like previous but without year, 'в' is russian letter
    if self.match(/[0-9][0-9]\.[0-9][0-9],.+/)
      return Time.new(Time.now.year, self[3..4], self[0..1], self[-5..-4], self[-2..-1])
    end
    # Question date mix from content attribute and pure text
    if self.match(/[0-9][0-9][0-9][0-9].+/)
      return Time.new(self[0..3], self[5..6], self[8..9], self[11..12], self[14..15])
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
    if self=='минуту назад' #
      return Time.now - 60
    end
    if self=='вчера'
      return Time.now - 60*60*24
    end

  end
end

user_agent = 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36'
cookie = 'toster_sid=r26mseclr84odkh2acrn9vg5u0; _gat=1; _ga=GA1.2.1258715546.1408355028; _ym_visorc_24049246=b'
#urls = [123539,125458,125460,125461]

# urls.each do |q|
#
#   QuestionPage.new(q,user_agent,cookie).get_answers.each do |answer|
#     puts "ANSWER USER :  nick = #{answer.user.nick}, rating = #{answer.user.rating}, answers = #{answer.user.answers} "
#     puts "ANSWER DATE = #{answer.created_at.to_s}"
#     answer.comments.each do |c|
#       puts "     COMMENT USER nick = #{c.user.nick}, rating = #{c.user.rating}, answers = #{c.user.answers} "
#       puts "     COMMENT DATE = #{c.created_at.to_s}"
#     end
#   end
# end

urls = QuestionPageList.get_questions_ids(user_agent, cookie)

puts "Parsed #{urls.count} questions"

urls.each_with_index  do |q,index|
  print("Inserting #{index} of #{urls.count} question           \r")
  begin
  question, answers = QuestionPage.new(q, user_agent, cookie).get_all
  rescue OpenURI::HTTPError => exception
    next
  end
  user_q = Tables::User.find_or_create(:nick => question.user.nick) { |user|
    user.questions = question.user.questions
    user.answers   = question.user.answers
    user.rating    = question.user.rating
    user.name      = question.user.name
  }

  Tables::Question.insert(
      :id             => nil,
      :descr          => question.descr,
      :user_id        => user_q.id,
      :views          => question.views,
      :created_at     => question.created_at,
      :likes          => question.likes,
      :title          => question.title,
      :comments_count => question.comments_count
  )
  question.comments.each do |comment|
    user_c = Tables::User.find_or_create(:nick => comment.user.nick) { |user|
      user.questions = comment.user.questions
      user.answers   = comment.user.answers
      user.rating    = comment.user.rating
      user.name      = comment.user.name
    }
    Tables::Comment.insert(
        :id          => nil,
        :descr       => comment.descr,
        :user_id     => user_c.id,
        :created_at  => comment.created_at,
        :resource_id => Tables::Question.last.id,
        :type        => 'question'
    )
  end
  tags_id =[]
  question.tags.each do |tag|
    tag__ = Tables::Tag.find_or_create(:tag => tag) { |tag_| tag_.tag=tag }
    tags_id << tag__.id
  end
  tags_id.each do |tag_id|
    Tables::QuestionsTag.insert(:id => nil, :tag_id => tag_id, :question_id => Tables::Question.last.id)
  end
  answers.each do |answer|
    user_a = Tables::User.find_or_create(:nick => answer.user.nick) { |user|
      user.questions = answer.user.questions
      user.answers   = answer.user.answers
      user.rating    = answer.user.rating
      user.name      = answer.user.name
    }
    Tables::Answer.insert(
        :id          => nil,
        :descr       => answer.descr,
        :likes       => answer.likes,
        :user_id     => user_a.id,
        :is_accepted => answer.is_accepted,
        :created_at  => answer.created_at,
        :question_id => Tables::Question.last.id
    )
    answer.comments.each do |comment|
      user_c = Tables::User.find_or_create(:nick => comment.user.nick) { |user|
        user.questions = comment.user.questions
        user.answers   = comment.user.answers
        user.rating    = comment.user.rating
        user.name      = comment.user.name
      }
      Tables::Comment.insert(
          :id          => nil,
          :descr       => comment.descr,
          :user_id     => user_c.id,
          :created_at  => comment.created_at,
          :type        => 'answer',
          :resource_id => Tables::Answer.last.id
      )
    end
  end
end

puts('Everything is OK')