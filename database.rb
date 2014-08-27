require 'sequel'
class DatabaseConnector
  Sequel.extension :inflector
  class << self
    attr_accessor :data_source
  end
  @data_source = 'sqlite://toster.db'
  db = Sequel.connect(DatabaseConnector.data_source)
  tables = %w(answers comments questions tags users)
  tables.each do |table|
    raise "Table '#{table}' does not exists or you have no permission to query" unless db.table_exists? table
    Kernel.const_set(table.classify, Class.new(Sequel::Model(db[table.to_sym])))
  end
end