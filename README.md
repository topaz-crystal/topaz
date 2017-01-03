<img src="https://cloud.githubusercontent.com/assets/3483230/20856901/fad1885e-b95f-11e6-848d-c46e33d8290e.png" width="100px"/>

# Topaz [![Build Status](https://travis-ci.org/topaz-crystal/topaz.svg?branch=master)](https://travis-ci.org/topaz-crystal/topaz)
[![Dependency Status](https://shards.rocks/badge/github/topaz-crystal/topaz/status.svg)](https://shards.rocks/github/topaz-crystal/topaz)
[![devDependency Status](https://shards.rocks/badge/github/topaz-crystal/topaz/dev_status.svg)](https://shards.rocks/github/topaz-crystal/topaz)

Topaz is a simple and useful db wrapper for crystal lang.
Topaz is inspired by active record design pattern, but not fully implemented.
See [sample code](https://github.com/topaz-crystal/topaz/blob/master/samples) for detail.
[Here](https://github.com/topaz-crystal/topaz-kemal-sample) is another sample that shows how Topaz works in Kemal.  
Depends on [crystal-lang/crystal-mysql](https://github.com/crystal-lang/crystal-mysql), [crystal-lang/crystal-sqlite3](https://github.com/crystal-lang/crystal-sqlite3) and [crystal-pg](https://github.com/will/crystal-pg)

## Installation
You can start to create a project with Topaz and Kamel by

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/topaz-crystal/topaz/master/tools/install.rb)"
```

If you want to add Topaz manually, add this to your application's `shard.yml`:

```yaml
dependencies:
  topaz:
    github: topaz-crystal/topaz
```

## Usage

**1. Setup DB**
```crystal
Topaz::Db.setup("mysql://root@localhost/topaz") # For MySQL
Topaz::Db.setup("postgres://root@localhost/topaz") # For PostgreSQL
Topaz::Db.setup("sqlite3://./db/data.db") # For SQLite3
```

**2. Define models**
```crystal
class SampleModel < Topaz::Model
  columns(
    name: String
  )
end

# You can drop or create a table
SampleModel.create_table
SampleModel.drop_table
```

**3. Create, find, update and delete models**
```crystal
s = SampleModel.create("Sample Name")

SampleModel.find(1).name
# => "Sample Name"
SampleModel.where("name = 'Sample Name'").size
# => 1
```
See [sample code](https://github.com/topaz-crystal/topaz/blob/master/samples/model.cr) for detail.

**4. Define associations between models**
```crystal
require "topaz"

class SampleParent < Topaz::Model
  columns # Empty columns
  has_many(childlen: {model: SampleChild, key: parent_id})
end

class SampleChild < Topaz::Model
  columns( # Define foreign key
    parent_id: Int32
  )
  belongs_to(parent: {model: SampleParent, key: parent_id})
end

p = SampleParent.create

child1 = SampleChild.create(p.id)
child2 = SampleChild.create(p.id)
child3 = SampleChild.create(p.id)

p.childlen.size
# => 3

child1.parent.id
# => 1
```
See [sample code](https://github.com/topaz-crystal/topaz/blob/master/samples/association.cr) for detail.  

**Other features**
* Transaction
* Table migration
* `Model#to_json` and `Model#from_json`
* `created_at` and `updated_at` column
* Nullable column

**Supported data types.**  
String, Int32, Int64, Float32, Float64  

## Contributing

1. Fork it ( https://github.com/topaz-crystal/topaz/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [tbrand](https://github.com/tbrand) Taichiro Suzuki - creator, maintainer
