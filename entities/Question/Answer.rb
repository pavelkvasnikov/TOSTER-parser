class Answer
  attr_reader :user, :descr, :likes, :comments, :created_at, :is_accepted

  def initialize(user, descr, likes, comments, created_at, is_accepted)
    @user = user
    @descr = descr
    @likes = likes
    @comments= comments
    @created_at = created_at
    @is_accepted = is_accepted
  end

end