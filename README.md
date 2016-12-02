# Topaz

Topaz is a simple and useful db wrapper for crystal lang.  
See [sample code](https://github.com/tbrand/topaz/blob/master/sample) for detail.  
Depends on [crystal-lang/crystal-mysql](https://github.com/crystal-lang/crystal-mysql)  

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
    ...
  )
end
```

**3. Create, find, update and delete models**  
See [sample code](https://github.com/tbrand/topaz/blob/master/sample/model.cr) for detail.

```crystal
require "topaz"

class SampleModel < Topaz::Model
  columns(
    {name: name, type: String},
    {name: age, type: Int32},
    {name: score, type: Int32},
    {name: time, type: Float64},
    {name: uid, type: Int32, primary: true}
  )
end

SampleModel.create_table

aaa = SampleModel.create("AAA", 25, 10, 20.0, 2)
bbb = SampleModel.create("BBB", 26, 12, 32.0, 3)
ccc = SampleModel.create("CCC", 25, 18, 40.0, 4)

SampleModel.select.size
# => 3

SampleModel.where("age = 25").select.size
# => 2

class SampleParent < Topaz::Model
  columns(
    {name: name, type: String},
    {has: SampleChild, as: childs}
  )
end

class SampleChild < Topaz::Model
  columns(
    {name: name, type: String},
    {name: parent_id, type: Int32, belongs: SampleParent, as: parent}
  )
end

p = SampleParent.create("Parent")

child1 = SampleChild.create("Child1", p.id)
child2 = SampleChild.create("Child2", p.id)
child3 = SampleChild.create("Child3", p.id)

p.childs.size
# => 3

child1.parent.name
# => Parent

```

See [sample code](https://github.com/tbrand/topaz/blob/master/sample/association.cr) for detail.  
**Supported data types.**
```
[MySQL]
String, Int32, Float64, Float32
[SQLite3]
String, Int64, Float64
```

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
