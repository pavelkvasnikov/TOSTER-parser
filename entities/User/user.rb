class User
  attr_accessor :nick,:rating,:answers,:questions,:name
  def initialize(nick=nil,rating=nil,answers=nil,questions=nil,name=nil)
    @nick=nick
    @rating = rating
    @answers = answers
    @questions=questions
    @name=name
  end
end