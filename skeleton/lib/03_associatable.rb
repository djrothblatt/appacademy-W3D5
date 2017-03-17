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
      class_name: name.to_s.camelcase
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
      foreign_key: "#{self_class_name.to_s.downcase}_id".to_sym,
      primary_key: :id,
      class_name: name.to_s.singularize.camelcase
    }
    merged_options = defaults.merge(options)
    @foreign_key = merged_options[:foreign_key]
    @class_name = merged_options[:class_name]
    @primary_key = merged_options[:primary_key]
  end
end

module Associatable
  # Phase IIIb
  # because this will *extend* SQLObject, these methods are *class* methods
  # so when self is passed into HasManyOptions.new, it refers to the *class*,
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options
    define_method(name) do
      foreign_key = self.send(options.foreign_key)
      target_class = options.model_class
      target_class.where(options.primary_key.to_sym => foreign_key).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)
    define_method(name) do
      primary_key = self.id
      source_class = options.model_class
      source_class.where(options.foreign_key => primary_key)
      # foreign_key = source_class.send(options.foreign_key)
      # foreign_key = self.send(options.foreign_key)
      # target_class = options.model_class
      # target_class.where(options.primary_key.to_sym => foreign_key)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
