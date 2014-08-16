class AnswerComment
  attr_reader :author, :descr, :created_at
  def initialize(author,descr,created_at)
    @author = author
    @descr = descr
    @created_at = created_at
  end
end