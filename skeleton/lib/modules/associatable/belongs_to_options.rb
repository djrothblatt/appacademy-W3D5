require_relative 'assoc_options'
require 'active_support/inflector'

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      foreign_key: "#{name}_id".to_sym,
      primary_key: :id,
      class_name: name.to_s.camelcase
    }
    merged_options = defaults.merge(options)
    @foreign_key = merged_options[:foreign_key]
    @class_name = merged_options[:class_name]
    @primary_key = merged_options[:primary_key]
  end
end
