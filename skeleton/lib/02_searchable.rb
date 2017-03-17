require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    keys, vals = params.keys, params.values
    where_string = keys.map { |key| "#{key} = ?" }.join(" AND ")
    data = DBConnection.execute(<<-SQL, *vals)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_string}
    SQL
    parse_all(data)
  end
end

class SQLObject
  extend Searchable
end
