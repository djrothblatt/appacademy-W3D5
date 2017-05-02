require_relative 'db_connection'
require_relative 'modules/associatable/associatable'
require_relative 'modules/searchable/searchable'
require 'active_support/inflector'

class SQLObject
  extend Associatable
  extend Searchable
  
  def self.columns # column_names?
    unless @columns # should probably limit 1...
      data = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{table_name}
        LIMIT
          1
      SQL
      @columns = data.first.map(&:to_sym)
    end

    @columns
  end

  def self.finalize! # 'create_accessors!'? private? make it a thing that you don't have to call explicitly
    SQLObject.columns.each do |column|
      define_method(column) { attributes[column] } # defines readers
      define_method("#{column}=") { |val| attributes[column] = val } # defines writers
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.to_s.tableize
  end

  def self.all
    data = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL
    parse_all(data)
  end

  def self.parse_all(results) # private?
    results.map { |datum| self.new(datum) }
  end

  def self.find(id)
    data = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        id = #{id}
    SQL
    parse_all(data).first
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      sym = attr_name.to_sym

      unless self.class.columns.include?(sym)
        raise "unknown attribute '#{attr_name}'"
      end

      self.send("#{sym}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |column|
      self.send(column)
    end
  end

  def insert
    cols = self.class.columns
    col_names = cols.join(', ')
    question_marks = (['?'] * cols.length).join(', ')
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    cols = self.class.columns
    col_bindings = cols.map { |col| "#{col} = ?"}.join(', ')
    DBConnection.execute(<<-SQL, *attribute_values)
      UPDATE
        #{self.class.table_name}
      SET
        #{col_bindings}
      WHERE
        id = #{self.id}
    SQL
  end

  def save
    if self.id
      update
    else
      insert
    end
  end
end
