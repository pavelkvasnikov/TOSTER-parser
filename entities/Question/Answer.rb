class Answer
  attr_reader :author, :descr, :likes, :comments, :created_at, :is_accepted

  def initialize(author, descr, likes, comments, created_at, is_accepted)
    @author = author
    @descr = descr
    @likes = likes
    @comments= comments
    @created_at = created_at
    @is_accepted = is_accepted
  end

end