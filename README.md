# Catwalk

Catwalk is a lightweight object-relational mapping, allowing you to
update a SQLite database while writing minimal SQL by hand.

## How to Use

To start using Catwalk, just clone this repo into your project.
In the examples below, Catwalk is cloned into the root of the project

Your models will inherit from SQLObject. Simply `require_relative`
SQLObject from wherever you place it in your project.

Models have all the normal CRUD methods (`create`, `update`, `destroy`,
`find`, `all`).

Models also have associations between tables.

The SQLObject::finalize! method creates reader and writer methods for
the columns of your table, so you must include it at the end of your
model definitions.

## Examples
### Creating an entry in a table
```ruby
require_relative 'catwalk/lib/sql_object'
class User < SQLObject
  finalize!
end

User.create(username: "connie", password: "password")
```

### Creating associations between tables
```ruby
require_relative 'lib/sql_object'
class User < SQLObject
  has_many :cats

  finalize!
end

class Cat < SQLObject
  belongs_to :owner,
    foreign_key: :user_id

  finalize!
end

User.first.cats
```
