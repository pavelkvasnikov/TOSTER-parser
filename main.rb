print "initializing...\r"
require 'nokogiri'
require 'sequel'
require 'open-uri'
require 'parallel'
require_relative 'database'
require_relative 'entities/Question/QuestionPage'
require_relative 'entities/Question/QuestionPageList'
require_relative 'String'
print "initializing... DONE\r"


user_agent = 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.124 Safari/537.36'
cookie = 'toster_sid=82bmv6utfl49hra0t5fmooelh5; _gat=1; _ga=GA1.2.1678308696.1403085862; _ym_visorc_24049246=b'
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

log_file = File.open('logs','w')

urls = QuestionPageList.get_questions_ids()
mutex = Mutex.new
puts "Parsed #{urls.count} questions"

Parallel.each_with_index(urls,:in_threads => 32)  do |q,index|
  print("Inserting #{index} of #{urls.count} question           \r")
  begin
  question, answers = QuestionPage.new(q, user_agent, cookie).get_all
  rescue OpenURI::HTTPError => exception
    log_file.puts "index = #{index}, exception text = #{exception}  , q = #{q}"
    next
  rescue Errno::ECONNREFUSED => exception_
    log_file.puts "index = #{index}, exception text = #{exception_} , q = #{q}"
    next
  rescue Errno::ETIMEDOUT => exception__
    log_file.puts "index = #{index}, exception text = #{exception__}, q = #{q}"
    sleep 6
    retry
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
f.close
puts('Everything is OK')