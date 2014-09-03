class String
  # Remember that by default 'Time.new' uses current system time zone with GMT
  # if you need UTC, convert it explicit with .utc
  def parse_date
    # Full date time format <DD.MM.YYYY, в hh:mm>, 'в' is russian letter
    if self.match(/[0-9][0-9]\.[0-9][0-9]\.[0-9][0-9][0-9][0-9],.+/)
      return Time.new(self[6..9], self[3..4], self[0..1], self[-5..-4], self[-2..-1])
    end
    # Partial date format <DD.MM, в hh:mm>, like previous but without year, 'в' is russian letter
    if self.match(/[0-9][0-9]\.[0-9][0-9],.+/)
      return Time.new(Time.now.year, self[3..4], self[0..1], self[-5..-4], self[-2..-1])
    end
    # Question date mix from content attribute and pure text
    if self.match(/[0-9][0-9][0-9][0-9].+/)
      return Time.new(self[0..3], self[5..6], self[8..9], self[11..12], self[14..15])
    end
    # Some hours ago
    if self.match(/[0-9]+ час.+/)
      return Time.now - (60*60*self[/[0-9]+/].to_i)
    end
    # Some minutes ago
    if self.match(/[0-9]+ мин.+/)
      return Time.now - (60*self[/[0-9]+/].to_i)
    end
    # An hour ago
    if self=='час назад'
      return Time.now - 60*60
    end
    # A minute ago
    if self=='минуту назад' #
      return Time.now - 60
    end
    if self=='вчера'
      return Time.now - 60*60*24
    end

  end
end