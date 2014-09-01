require 'sequel'
module Tables

end
class DatabaseConnector
  Sequel.extension :inflector
  class << self
    attr_accessor :data_source
  end
  @data_source = 'sqlite://tosternew'
  db = Sequel.connect(DatabaseConnector.data_source)
  tables = %w(answers comments questions tags questions_tags users )
  tables.each do |table|

   # raise "Table '#{table}' does not exists or you have no permission to query" unless db.table_exists? table
   Tables.const_set(table.classify, Class.new(Sequel::Model(db[table.to_sym])))
  end
  print("Checking db  DONE \r\n")
end