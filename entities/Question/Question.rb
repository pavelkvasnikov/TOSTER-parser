# Representation of singe properties like <title>, <description> of page with question

class Question
  attr_reader :title,:descr,:likes,:created_at,:user,:views,:comments_count, :tags
  def initialize(title,descr,likes,created_at,user,views,comments_count,tags)
    @title=title
    @descr=descr
    @likes=likes
    @created_at=created_at
    @user= user
    @views= views
    @comments_count= comments_count
    @tags = tags
  end
end