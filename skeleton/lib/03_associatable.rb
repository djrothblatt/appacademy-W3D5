require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name || class_name.tableize
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      foreign_key: "#{name}_id".to_sym,
      primary_key: "id".to_sym,
      class_name: name.camelcase
    }
    merged_options = defaults.merge(options)
    @foreign_key = merged_options[:foreign_key]
    @class_name = merged_options[:class_name]
    @primary_key = merged_options[:primary_key]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @name = name
    defaults = {
      foreign_key: "#{self_class_name.downcase}_id".to_sym,
      primary_key: "id".to_sym,
      class_name: name.singularize.camelcase
    }
    merged_options = defaults.merge(options)
    @foreign_key = merged_options[:foreign_key]
    @class_name = merged_options[:class_name]
    @primary_key = merged_options[:primary_key]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
end
