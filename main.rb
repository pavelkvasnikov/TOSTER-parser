require 'nokogiri'
require 'sequel'
require 'open-uri'
require_relative 'database'
require 'net/smtp'



db = Sequel.connect('sqlite://toster.db')
users= db[:users]

user_agent = 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36'
cookie = 'toster_sid=ae5ej6ohrfnt4s06ojrt5r5ng0; _dc=1; _ga=GA1.2.1678308696.1403085862; _ym_visorc_24049246=b'
exit 0
(1..589).each do |index|

  page =Nokogiri::HTML(open('http://toster.ru/users/main?page='+index.to_s, {'User-Agent' => user_agent, 'Cookie' => cookie}))
  page.css('div.users_list_item').each do |el|
    users.insert(:nick      =>  el.css('div.login').text,
                 :rating    =>  el.css('div.rating a b').text,
                 :answers   =>  el.css('div.answers_count a b').text,
                 :questions =>  el.css('div.questions_count a b').text,
                 :name      =>  el.css('div.fullname a').text
    )
  end
  print "parsed #{index} of 589, #{(index/589.0*100.0).round}%                          \r"
end



