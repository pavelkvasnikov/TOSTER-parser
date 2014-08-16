require 'nokogiri'
require 'sequel'
require 'open-uri'
require_relative 'database'
require_relative 'entities/Question/QuestionPage'



user_agent = 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36'
cookie = 'toster_sid=ae5ej6ohrfnt4s06ojrt5r5ng0; _dc=1; _ga=GA1.2.1678308696.1403085862; _ym_visorc_24049246=b'



# page = Nokogiri::HTML(open('http://toster.ru/q/118059', {'User-Agent' => user_agent||'', 'Cookie' => cookie||''}) )
# tags =[]

# puts tags
# exit 0






answers = QuestionPage.new(95401,user_agent,cookie)
answers.get_answers.each do |answer|
  print "AUTHOR = #{answer.author} \n"
  print "DESCR = #{answer.descr[0..15]}  \n"
  print "LIKES = #{answer.likes}  \n"
  print "-------------------------------\n"

end


