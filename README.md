<img src="https://cloud.githubusercontent.com/assets/3483230/20856901/fad1885e-b95f-11e6-848d-c46e33d8290e.png" width="100px"/>

# Topaz
[![Dependency Status](https://shards.rocks/badge/github/tbrand/topaz/status.svg)](https://shards.rocks/github/tbrand/topaz)
[![devDependency Status](https://shards.rocks/badge/github/tbrand/topaz/dev_status.svg)](https://shards.rocks/github/tbrand/topaz)

Topaz is a simple and useful db wrapper for crystal lang.
Topaz is inspired by active record design pattern, but not fully implemented.
See [sample code](https://github.com/tbrand/topaz/blob/master/samples) for detail.
[Here](https://github.com/tbrand/topaz-kemal-sample) is another sample that shows how Topaz works in Kemal.  
Depends on [crystal-lang/crystal-mysql](https://github.com/crystal-lang/crystal-mysql) and [crystal-lang/crystal-sqlite3](https://github.com/crystal-lang/crystal-sqlite3)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  topaz:
    github: tbrand/topaz
```

## Usage

**1. Setup DB**
```crystal
Topaz::Db.setup("mysql://root@localhost/topaz") # For MySQL
Topaz::Db.setup("sqlite3://./db/data.db") # For SQLite3
```

**2. Define models**
```crystal
class SampleModel < Topaz::Model
  columns(
    {name: name, type: String}
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
See [sample code](https://github.com/tbrand/topaz/blob/master/samples/model.cr) for detail.

**4. Define associations between models**
```crystal
require "topaz"

class SampleParent < Topaz::Model
  columns # Empty columns
  has_many( {model: SampleChild, as: childs, key: parent_id} )
end

class SampleChild < Topaz::Model
  columns( # Define foreign key
    {name: parent_id, type: Int32}
  )
  belongs_to( {model: SampleParent, as: parent, key: parent_id} )
end

p = SampleParent.create

child1 = SampleChild.create(p.id)
child2 = SampleChild.create(p.id)
child3 = SampleChild.create(p.id)

p.childs.size
# => 3

child1.parent.id
# => 1
```
See [sample code](https://github.com/tbrand/topaz/blob/master/samples/association.cr) for detail.  

**Supported data types.**  

[MySQL]  
String, Int32, Float64, Float32

[SQLite3]  
String, Int64, Float64  

TODO:
* Support DATE
* Support migration.

## Contributing

1. Fork it ( https://github.com/tbrand/topaz )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [tbrand](https://github.com/tbrand) Taichiro Suzuki - creator, maintainer
