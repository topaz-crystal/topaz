# Topaz

Topaz is a db wrapper for crystal lang.  
The model is transparent for db that doesn't require throwing any queries.  
Topaz also supports create/drop tables.  
See [sample code](https://github.com/tbrand/topaz/blob/master/sample/model.cr) for detail.  
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
```
Topaz.setup("mysql://root@localhost/topaz")
```

**2. Define models**
```
class SampleModel < Topaz::Model
  attrs(
    {name: name, type: String}
    ...
  )
end
```

**3. Create, find, update and delete models**
See [sample code](https://github.com/tbrand/topaz/blob/master/sample/model.cr)

```crystal
require "topaz"

class SampleModel < Topaz::Model
  attrs(
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
  
  attrs(
    {name: name, type: String}
  )

  has({model: SampleChild, as: childs, id: parent_id})
end

class SampleChild < Topaz::Model
  attrs(
    {name: name, type: String},
    {name: parent_id, type: Int32}
  )

  belongs({model: SampleParent, as: parent, id: parent_id})
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

For detail, see sample code.

TODO:
* Support DATE
* Support SQLite
* Support migration.

## Contributing

1. Fork it ( https://github.com/tbrand/topaz )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [tbrand](https://github.com/tbrand) Taichiro Suzuki - creator, maintainer
