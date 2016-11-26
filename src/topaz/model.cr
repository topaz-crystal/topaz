require "mysql"

module Topaz
  # Simple and useful db wrapper for crystal-lang.
  # Expending this class activate topaz.
  # ```
  # class SampleModel < Topaz::Model
  # end
  # ```
  class Model
    # attrs define attributes for Topaz::Model.
    # Use NamedTuple as arguments.
    # 'name' key defines a name of the column.
    # 'type' key defines a type of the column.
    # Currently, String, Int32, Float32 and Float64 are supported.
    # 'primary' is also supported for primary key.
    # ```
    # attrs(
    #   {name: name, type: String},
    #   {name: primary_id, type: Int32, primary: true}
    # )
    # ```
    # attrs generates a constructor for the model.
    # The constructor doesn't require any keys, the order of the arguments is same as order of attrs.
    # ```
    # s = SampleModel.create("MyName", 3)
    # ```
    # Every model has 'id' as an idetifier, 'id' is automatically defined even if you don't define it in attrs.
    # Futhemore, you should not define it in attrs that may raise compile error.
    # See [sample code](https://github.com/tbrand/topaz/blob/master/sample/model.cr) for detail.
    macro attrs(*cols)

      def initialize(
            {% for ch in cols %}
              @{{ch[:name]}} : {{ch[:type]}}|Nil,
            {% end %}@q = "")
      end

      protected def initialize(
            @id : Int32 | Nil,
            {% for ch in cols %}
              @{{ch[:name]}} : {{ch[:type]}}|Nil,
            {% end %}@q = "")
      end

      protected def initialize
        {% for ch in cols %}
          @{{ch[:name]}} = nil
        {% end %}
          @q = ""
      end

      def id
        return @id
      end

      protected def query(q)
        @q = q
        self
      end

      def self.find(id)
        new.query("where id = #{id}").select.first
      end

      def self.where(q : String)
        new.query("where #{q} ")
      end

      def self.order(column : String, sort = "asc")
        new.query("order by #{column} #{sort} ")
      end

      def self.range(offset : Int, limit : Int)
        new.query("limit #{limit} offset #{offset} ")
      end

      def self.select
        new.select
      end

      def self.update(data)
        new.update(data)
      end
      
      def self.delete
        new.delete
      end
      
      def and(q : String)
        @q = "#{@q}and #{q} "
        self
      end

      def or(q : String)
        @q = "#{@q}or #{q} "
        self
      end
      
      def order(column : String, sort = "asc")
        @q = "#{@q}order by #{column} #{sort} "
        self
      end

      def range(offset : Int, limit : Int)
        @q = "#{@q}limit #{limit} offset #{offset} "
        self
      end

      def delete
        @q = "where id = #{@id}" unless @id.nil?
        @q = "delete from #{table_name} #{@q}"
        exec
        @q = ""
      end

      def update(data)

        @q = "where id = #{@id}" unless @id.nil?

        updated = ""
        
        data.each_with_index do |k, v, idx|
          unless v.nil?
            updated += "#{k} = \'#{v}\'"
            updated += ", " if idx != data.size-1
            set_value_of(k.to_s, v) unless @id.nil?
          end
        end
        
        @q = "update #{table_name} set #{updated} #{@q}"
        exec
        @q = ""
      end

      def update
        {% if cols.size > 0 %}
          data = { {% for ch in cols %}{{ch[:name]}}: @{{ch[:name]}},{% end %} }
          update(data)
        {% end %}
      end

      # This function is a trigger of the 'SELECT' query
      # Every 'SELECT' related methods will not be launched without calling this
      def select
        
        @q = "select * from #{table_name} #{@q}"
        Topaz::Logger.q @q
        
        set = Array(typeof(self)).new
        
        DB.open Topaz.env do |db|
          db.query(@q) do |res|
            res.each do
              set.push(
                typeof(self).new(
                res.read(Int32), # id
                {% for ch in cols %}
                  res.read({{ch[:type]}}|Nil),
                {% end %}
              ))
            end
          end
        end
        
        set
      end
      
      def self.create({% for ch in cols %}{{ch[:name]}} : {{ch[:type]}}|Nil,{% end %})
        model = new({% for ch in cols %}{{ch[:name]}},{% end %})
        res = model.save
        model
      end
      
      def save

        keys = [] of String
        vals = [] of String

        {% for ch in cols %}
          keys.push("{{ch[:name]}}") unless @{{ch[:name]}}.nil?
          vals.push("'#{@{{ch[:name]}}}'") unless @{{ch[:name]}}.nil?
        {% end %}
          
          _keys = keys.join(", ")
        _vals = vals.join(", ")

        @q = "insert into #{table_name}(#{_keys}) values(#{_vals})"
        res = exec
        @q = ""
        @id = res.last_insert_id.to_i32
      end
      
      def to_a
        [
          ["id", @id],
          {% for ch in cols %}["{{ch[:name]}}", @{{ch[:name]}}],{% end %}
        ]
      end
      
      def to_h
        {
          "id" => @id,
          {% for ch in cols %}"{{ch[:name]}}" => @{{ch[:name]}},{% end %}
        }
      end
      
      def value_of(key : String)
        case key
        when "id"
          @id
          {% for ch in cols %}
          when "{{ch[:name]}}"
            @{{ch[:name]}}
          {% end %}
        end
      end
      
      def set_value_of(key : String, value : DB::Any)
        {% if cols.size > 0%}
          case key
              {% for ch in cols %}
              when "{{ch[:name]}}"
                @{{ch[:name]}} = value
              {% end %}
          end
        {% end %}
      end
      
      def self.create_table
        query = "create table if not exists #{table_name}(id int auto_increment,{% for ch in cols %}{{ch[:name]}} #{get_type({{ch[:type]}})}{% if !ch[:primary].nil? && ch[:primary] %} primary key{% end %},{% end %}index(id))"
        exec query
      end
      
      def self.drop_table
        query = "drop table if exists #{table_name}"
        exec query
      end

      def exec
        Topaz::Logger.q @q
        DB.open Topaz.env do |db|
          return db.exec @q
        end
      end

      protected def self.exec(q)
        new.query(q).exec
      end

      def self.table_name
        self.to_s.gsub("::", '_').downcase
      end

      def table_name
        typeof(self).to_s.gsub("::", '_').downcase
      end

      def self.parent_id
        self.to_s.gsub("::", '_').downcase + "_id"
      end

      private def self.get_type(t)
        case t.to_s
        when "String"
          "text"
        when "Int32"
          "int"
        when "Float32"
          "float"
        when "Float64"
          "double"
        end
      end
      
      {% for ch in cols %}
        def {{ch[:name]}}=(@{{ch[:name]}} : {{ch[:type]}})
        end
        
        def {{ch[:name]}}
          return @{{ch[:name]}}
        end
      {% end %}
    end

    # You can define relations for each model by 'belongs' and 'has' macros.
    # 'belongs' meant that the model belongs to the parent model you specified.
    # This macro relates to 'has' macro.
    # The arguments of 'belongs' are NamedTuple, and 'model', 'as' and 'id' keys are needed.
    # 'model' key is a type of parent class.
    # 'as' key is a accessible name for the parent.
    # 'id' key is a name of the parent's id that you have to define it in attrs of the child as Int32.
    # ```
    # class SampleChild < Topaz::Model
    #   attrs({name: parent_id, type: Int32})
    #   belongs({model: SampleParent, as: parent, id: parent_id})
    # end
    # ```
    # See [sample code](https://github.com/tbrand/topaz/blob/master/sample/model.cr) for the usages.
    macro belongs(*models)
      {% for m in models %}
        def {{m[:as]}}
          {% if m[:id] != nil %}
            {{m[:model]}}.find(@{{m[:id]}})
          {% else %}
            {{m[:model]}}.find(typeof(self).parent_id)
          {% end %}
        end
      {% end %}
    end

    # You can define relations for each model by 'belongs' and 'has' macros.
    # 'has' meant that the model has multiple child models you specified.
    # This macro relates to 'belongs' macro.
    # The arguments of 'has' are NamedTuple, and 'model', 'as' and 'id' keys are needed.
    # 'model' key is a type of parent class.
    # 'as' key is a accessbiel name for the childs
    # 'id' key is a name of the parent's id that you have to define it in attrs of the child as Int32.
    # ```
    # class SampleParent < Topaz::Model
    #   has({model: SampleChild, as: childs, id: parent_id})
    # end
    # ```
    # See [sample code](https://github.com/tbrand/topaz/blob/master/sample/model.cr) for the usages.
    macro has(*models)
      {% for m in models %}
        def {{m[:as]}}
          {% if m[:id] != nil%}
            {{m[:model]}}.where("{{m[:id]}} = #{@id}").select
          {% else %}
            {{m[:model]}}.where("#{typeof(self).parent_id} = #{@id}").select
          {% end %}
        end
      {% end %}
    end
  end
end
