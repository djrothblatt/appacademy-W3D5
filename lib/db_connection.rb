require 'sqlite3'

PRINT_QUERIES = ENV['PRINT_QUERIES'] == 'true'
DB_FOLDER = File.join(File.dirname(__FILE__), '..')

class DBConnection
  def self.db_filename=(db_filename)
    @@db_filename = DB_FOLDER + db_filename
  end

  def self.db_filename
    @@db_filename
  end

  def self.open(db_filename)
    self.db_filename = db_filename
    @db = SQLite3::Database.new(@@db_filename)
    @db.results_as_hash = true
    @db.type_translation = true

    @db
  end

  def self.reset
    sql_filename = @@db_filename[0...-3]
    commands = [
      "rm '#{@@db_filename}'",
      "cat '#{sql_filename}' | sqlite3 '#{@@db_filename}'"
    ]

    commands.each { |command| `#{command}` }
    DBConnection.open(@@db_filename)
  end

  def self.instance
    reset if @db.nil?

    @db
  end

  def self.execute(*args)
    print_query(*args)
    instance.execute(*args)
  end

  def self.execute2(*args)
    print_query(*args)
    instance.execute2(*args)
  end

  def self.last_insert_row_id
    instance.last_insert_row_id
  end

  private

  def self.print_query(query, *interpolation_args)
    return unless PRINT_QUERIES

    puts '--------------------'
    puts query
    unless interpolation_args.empty?
      puts "interpolate: #{interpolation_args.inspect}"
    end
    puts '--------------------'
  end
end
