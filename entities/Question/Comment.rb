class Comment
  attr_reader :user, :descr, :created_at, :type
  def initialize(user,descr,created_at, type)
    @user = user
    @descr = descr
    @created_at = created_at
    @type = type
  end
end