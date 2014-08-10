require 'nokogiri'
require 'sequel'
require 'open-uri'
require_relative 'database'

User.limit(5).each { |t| puts t[:nick]+' '+t[:rating].to_s }
exit
user_agent = 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36'
cookie = 'toster_sid=ae5ej6ohrfnt4s06ojrt5r5ng0; _dc=1; _ga=GA1.2.1678308696.1403085862; _ym_visorc_24049246=b'




