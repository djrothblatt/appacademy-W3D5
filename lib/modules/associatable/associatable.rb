require 'active_support/inflector'
require_relative 'belongs_to_options'
require_relative 'has_many_options'

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options
    define_method(name) do
      foreign_key = self.send(options.foreign_key)
      target_class = options.model_class
      target_class.where(options.primary_key.to_sym => foreign_key).first
    end
  end

  # because Associatable will *extend* SQLObject, these methods are *class* methods
  # so when self is passed into HasManyOptions.new, it refers to the *class*
  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)
    define_method(name) do
      primary_key = self.id
      source_class = options.model_class
      source_class.where(options.foreign_key => primary_key)
    end
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      through_table_name = through_options.table_name
      source_table_name  = source_options.table_name

      data = DBConnection.execute(<<-SQL)
        SELECT
          #{source_table_name}.*
        FROM
          #{through_table_name}
        JOIN
          #{source_table_name}
        ON
          #{source_options.foreign_key} = #{source_table_name}.id
        WHERE
          #{through_table_name}.id = #{source_options.foreign_key}
      SQL
      source_options.model_class.parse_all(data).first
    end
  end
  
  def assoc_options
    @assoc_options ||= {}
  end
end
