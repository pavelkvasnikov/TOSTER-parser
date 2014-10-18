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
cookie = 'toster_sid=8898hi0bim08pru0kav85iq745; _gat=1; _ga=GA1.2.674143056.1413212318; _ym_visorc_24049246=b'


log_file = File.open('logs','a')

urls = QuestionPageList.get_questions_ids

puts "Parsed #{urls.count} questions"

Parallel.each_with_index(urls,:in_threads => 4)  do |q,index|
  next unless Tables::Question.where(:link_id => q).nil?
  print("Inserting #{index} of #{urls.count} question           \r")
  begin
  question, answers = QuestionPage.new(q,user_agent,cookie).get_all
  rescue OpenURI::HTTPError => exception
    log_file.print "index = #{index}, exception text = #{exception}  , q = #{q} \n"
    next
  rescue Errno::ECONNREFUSED => exception_
    log_file.print "index = #{index}, exception text = #{exception_} , q = #{q} \n"
    next
  rescue Errno::ETIMEDOUT => exception__
    log_file.print "index = #{index}, exception text = #{exception__}, q = #{q} \n"
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
      :comments_count => question.comments_count,
      :link_id        => q
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
log_file.close
puts('Everything is OK')