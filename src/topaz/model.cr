# This is a main wrapper class for models.
# Any class extending Topaz::Model can be transparent models for databases.
module Topaz
  class Model
    macro columns(*cols)

      {% data_exists = false %}
      {% for c in cols %}
        {% if c[:name].id != nil %}
          {% data_exists = true %}
        {% end %}
      {% end %}

      def initialize(
            {% for c in cols %}
              {% if c[:name].id != nil %}
                @{{c[:name].id}} : {{c[:type].id}},
              {% end %}
            {% end %}@q = "", @id = -1)
      end

      protected def initialize(
                      @id : Int32,
                      {% for c in cols %}
                        {% if c[:name] != nil %}
                          @{{c[:name].id}} : {{c[:type].id}},
                        {% end %}
                      {% end %}@q = "")
      end

      protected def initialize
        {% for c in cols %}
          {% if c[:name] != nil %}
            @{{c[:name].id}} = nil
          {% end %}
        {% end %}
          @id = -1
          @q = ""
      end

      def id
        return @id
      end

      def query(q)
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

      def self.join(model, column : String, foreign_key : String)
        new.query("join #{model.table_name} on #{table_name}.#{foreign_key}=#{model.table_name}.#{column} ")
      end

      def where(q : String)
        @q = "#{@q}where #{q} "
        self
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
        @q = "where id = #{@id}" unless @id == -1
        @q = "delete from #{table_name} #{@q}"
        exec
        @q = ""
      end

      def update(data)
        @q = "where id = #{@id}" unless @id == -1

        updated = ""

        data.each_with_index do |k, v, i|
          unless v.nil?
            updated += "#{k} = \'#{v}\'"
            updated += ", " if i != data.size-1
            set_value_of(k.to_s, v) unless @id == -1
          end
        end

        @q = "update #{table_name} set #{updated} #{@q}"
        exec
        @q = ""
      end

      def update
        {% if cols.size > 0 && data_exists %}
          data = { {% for c in cols %}{% if c[:name] != nil %}{{c[:name].id}}: @{{c[:name].id}},{% end %}{% end %} }
          update(data)
        {% end %}
      end

      def select

        @q = "select * from #{table_name} #{@q}"
        Topaz::Log.q @q

        #set = Array(typeof(self)).new
        set = Set.new

        Topaz::Db.open do |db|
          db.query(@q) do |res|
            res.each do
              case Topaz::Db.type
              when :mysql
                set.push(
                  typeof(self).new(
                  res.read(Int32), # id
                  {% for c in cols %}
                    {% if c[:name] != nil %}
                      res.read({{c[:type].id}}),
                    {% end %}
                  {% end %}
                ))
              when :sqlite3
                set.push(
                  typeof(self).new(
                  res.read(Int64).to_i32, # id
                  {% for c in cols %}
                    {% if c[:name] != nil %}
                      res.read({{c[:type].id}}),
                    {% end %}
                  {% end %}
                ))
              end
            end
          end
        end

        set
      end

      def self.create({% for c in cols %}{% if c[:name] != nil %}{{c[:name].id}} : {{c[:type].id}},{% end %}{% end %})
        model = new({% for c in cols %}{% if c[:name] != nil %}{{c[:name].id}},{% end %}{% end %})
        res = model.save
        model
      end

      def save

        keys = [] of String
        vals = [] of String

        {% for c in cols %}
          {% if c[:name] != nil %}
            keys.push("{{c[:name].id}}") unless @{{c[:name].id}}.nil?
            vals.push("'#{@{{c[:name].id}}}'") unless @{{c[:name].id}}.nil?
          {% end %}
        {% end %}

        _keys = keys.join(", ")
        _vals = vals.join(", ")

        @q = "insert into #{table_name} values(null)" if _vals.empty?
        @q = "insert into #{table_name}(#{_keys}) values(#{_vals})" unless _vals.empty?

        res = exec
        @q = ""
        @id = res.last_insert_id.to_i32
        self
      end

      def to_a
        [
          ["id", @id],
          {% for c in cols %}{% if c[:name] != nil %}["{{c[:name].id}}", @{{c[:name].id}}],{% end %}{% end %}
        ]
      end

      def to_h
        {
          "id" => @id,
          {% for c in cols %}{% if c[:name] != nil %}"{{c[:name].id}}" => @{{c[:name].id}},{% end %}{% end %}
        }
      end

      def self.create_table

        case Topaz::Db.type
        when :mysql
          query = "create table if not exists #{table_name}(id int auto_increment,{% for c in cols %}{% if c[:name] != nil %}{{c[:name].id}} #{get_type({{c[:type].id}})}{% if !c[:primary].nil? && c[:primary] %} primary key{% end %},{% end %}{% end %}index(id))"
        when :sqlite3
          query = "create table if not exists #{table_name}(id integer primary key{% for c, i in cols %}{% if c[:name] != nil && data_exists %}, {{c[:name].id}} #{get_type({{c[:type].id}})}{% if !c[:primary].nil? && c[:primary] %} primary key{% end %}{% end %}{% end %})"
        else
          query = ""
        end

        exec query
      end

      def self.drop_table
        query = "drop table if exists #{table_name}"
        exec query
      end

      def exec
        Topaz::Log.q @q
        Topaz::Db.open do |db|
          return db.exec @q
        end
      end

      protected def self.exec(q)
        new.query(q).exec
      end

      protected def self.downcase
        class_name = self.to_s.gsub("::", '_')
        class_name = class_name.gsub(/[A-Z]/){ |a| '_' + a.downcase }
        class_name = class_name[1..class_name.size-1] if class_name.starts_with?('_')
        class_name
      end

      def self.table_name
        downcase
      end

      def table_name
        typeof(self).downcase
      end

      private def self.get_type(t)
        case t.to_s
        when "String"
          "text"
        when "Int32"
          return "int" if Topaz::Db.type == :mysql
          return "integer" if Topaz::Db.type == :sqlite3
        when "Int64"
          return "int" if Topaz::Db.type == :mysql
          return "integer" if Topaz::Db.type == :sqlite3
        when "Float32"
          "float"
        when "Float64"
          "double"
        end
      end

      protected def set_value_of(key : String, value : DB::Any)

        {% if cols.size > 0 && data_exists %}
          case key
              {% for c in cols %}
                {% if c[:name] != nil %}
                when "{{c[:name].id}}"
                  @{{c[:name].id}} = value
                {% end %}
              {% end %}
          end
        {% end %}
      end

      protected def as_json(only : Array(Symbol), except : Array(Symbol))

        json = ""

        to_h.keys.each do |key|

          is_string? = to_h[key].class == String

          Topaz::Log.w "only and except is set at the same time\nexcept will be ignored" if only.size > 0 && except.size > 0

          add = !only.find{ |o| o.to_s == key }.nil? if only.size > 0
          add = except.find{ |e| e.to_s == key }.nil? if except.size > 0 && add.nil?
          add = true if add.nil?

          if add
            json += "\"#{key}\": \"#{to_h[key]}\"" if is_string?
            json += "\"#{key}\": #{to_h[key]}" unless is_string?
            json += ", "
          end
        end

        raise "No json element found with your option" if json.size < 3

        json[0..json.size-3]
      end

      def json(options : NamedTuple|Nil = nil)

        included = ""
        only     = [] of Symbol
        except   = [] of Symbol

        unless options.nil?
          options.each_key do |k|
            if k.to_s == "include"
              if options[k].is_a?(Symbol)
                ms = elements(options[k].as(Symbol))
                included += ", \"#{options[k]}\": #{ms.json}" unless ms.nil?
              elsif options[k].is_a?(NamedTuple)
                options[k].as(NamedTuple).each_key do |_k|
                  eles = elements(_k)
                  included += ", \"#{_k}\": #{eles.json(options[k][_k])}" unless eles.nil?
                end
              end
            elsif k.to_s == "except"
              except = options[k].as(Array(Symbol)) if options[k].is_a?(Array(Symbol))
              except = [ options[k].as(Symbol) ] if options[k].is_a?(Symbol)
            elsif k.to_s == "only"
              only = options[k].as(Array(Symbol)) if options[k].is_a?(Array(Symbol))
              only = [ options[k].as(Symbol) ] if options[k].is_a?(Symbol)
            end
          end
        end

        "{#{as_json(only, except)}#{included}}"
      end

      class Set < Array(self)
        def json(options : NamedTuple|Nil = nil)

          json = "["
          each_with_index do |m, i|
            json += "#{m.json(options)}"
            json += ", " if i != size-1
          end
          json += "]"
          json
        end
      end

      {% for c in cols %}
        def {{c[:name].id}}=(@{{c[:name].id}} : {{c[:type].id}})
        end

        def {{c[:name].id}} : {{c[:type].id}}
          return @{{c[:name].id}}.as({{c[:type].id}})
        end

      {% end %}
    end

    macro has_many(*models)
      {% for m in models %}
        def {{m[:as].id}}
          {{m[:model].id}}
            .where("{{m[:key].id}} = #{@id}").select
        end
      {% end %}

        def elements(ms : Symbol|String)
          {% if models.size > 0 %}
            case ms
                {% for m in models %}
                when :{{m[:as].id}}, "{{m[:as].id}}"
                  return {{m[:as].id}}
                {% end %}
            end
          {% end %}
            raise "No such elements #{ms} in #{typeof(self)}"
        end
    end

    def elements(dummy : Symbol)
      nil
    end

    macro belongs_to(*models)
      {% for m in models %}
        def {{m[:as].id}}
          {{m[:model].id}}.find({{m[:key].id}})
        end
      {% end %}
    end
  end
end
