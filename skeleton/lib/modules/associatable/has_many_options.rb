require_relative 'assoc_options'
require 'active_support/inflector'

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
