require "json"

# This is a main wrapper class for Topaz models.
# Any class extending Topaz::Model can be transparent models for any databases.
# The model have to call `columns` macro even if you don't have any columns
# since the calling contruct every necessary functions
module Topaz
  class Model
    TIME_FORMAT = "%F %T:%L %z"
    getter created_at : Time | Nil
    getter updated_at : Time | Nil

    @id = -1
    @q : String?
    @tx : DB::Transaction?

    macro columns(cols)

      JSON.mapping(
        id: Int32,
        {% for key, value in cols %}
          {% if value.is_a?(NamedTupleLiteral) %}
            {{key}}: {{value[:type]}}|Nil,
          {% else %}
            {{key}}: {{value.id}}|Nil,
          {% end %}
        {% end %}
        created_at: Time|Nil,
        updated_at: Time|Nil)

      def initialize({% for key, value in cols %}
                       {% if value.is_a?(NamedTupleLiteral) %}
                         {% if value[:nullable] %}
                           @{{key.id}} : {{value[:type]}}|Nil,
                         {% else %}
                           @{{key.id}} : {{value[:type]}},
                         {% end %}
                       {% else %}
                         @{{key.id}} : {{value.id}},
                       {% end %}
                     {% end %})
      end

      protected def initialize(@id : Int32,
                               {% for key, value in cols %}
                                 {% if value.is_a?(NamedTupleLiteral) %}
                                   {% if value[:nullable] %}
                                     @{{key.id}} : {{value[:type]}}|Nil,
                                   {% else %}
                                     @{{key.id}} : {{value[:type]}},
                                   {% end %}
                                 {% else %}
                                   @{{key.id}} : {{value.id}},
                                 {% end %}
                               {% end %}created_at : String, updated_at : String)
        @created_at = Time.parse(created_at, TIME_FORMAT)
        @updated_at = Time.parse(updated_at, TIME_FORMAT)
      end

      protected def initialize
        {% for key, value in cols %}
          @{{key.id}} = nil
        {% end %}
      end

      protected def set_query(q)
        @q = q
        self
      end

      def self.in(tx : DB::Transaction)
        new.in(tx)
      end

      def self.find(id)
        new.set_query("where id = #{id}").select.first
      end

      def self.where(q : String)
        new.set_query("where #{q} ")
      end

      def self.order(column : String, sort = "asc")
        new.set_query("order by #{column} #{sort} ")
      end

      def self.range(offset : Int, limit : Int)
        new.set_query("limit #{limit} offset #{offset} ")
      end

      def self.select
        new.select
      end

      def self.update(**data)
        new.update(**data)
      end

      def self.delete
        new.delete
      end

      def in(tx : DB::Transaction)
        @tx = tx
        self
      end

      def find(id)
        model = typeof(self).new
        model.in(@tx.as(DB::Transaction)) unless @tx.nil?
        model.set_query("where id = #{id}").select.first
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

      def update(**data)

        @q = "where id = #{@id}" unless @id == -1

        updated = ""

        time = Time.now

        if data.keys.size == 0
          {% for key, value, idx in cols %}
            {% if value.is_a?(NamedTupleLiteral) %}
              {% if value[:nullable] %}
                updated += "{{key}} = \'#{@{{key}}}\', " unless @{{key}}.nil?
                updated += "{{key}} = null, " if @{{key}}.nil?
              {% else %}
                updated += "{{key}} = \'#{@{{key}}}\', " unless @{{key}}.nil?
              {% end %}
            {% else %}
              updated += "{{key}} = \'#{@{{key}}}\', " unless @{{key}}.nil?
            {% end %}
          {% end %}
        else
          data.each_with_index do |key, value, idx|
            unless value.nil?
              updated += "#{key} = \'#{value}\', "
              set_value_of(key.to_s, value) unless @id == -1
            else
              updated += "#{key} = null, "
              set_value_of(key.to_s, value) unless @id == -1
            end
          end
        end

        updated += "updated_at = \'#{time.to_s(TIME_FORMAT)}\'"

        @updated_at = time

        @q = "update #{table_name} set #{updated} #{@q}"
        exec
        @q = ""
      end

      protected def set_value_of(_key : String, _value : DB::Any)
        {% if cols.size > 0 %}
          case _key
            {% for key, value in cols %}
            when "{{key.id}}"
              {% if value.is_a?(NamedTupleLiteral) %}
                @{{key.id}} = _value if _value.is_a?({{value[:type]}})
              {% else %}
                @{{key.id}} = _value if _value.is_a?({{value.id}})
              {% end %}
            {% end %}
          end
        {% end %}
      end

      def select
        @q = "select * from #{table_name} #{@q}"
        Topaz::Log.q @q.as(String), @tx unless @q.nil?

        res = read_result(Topaz::Db.shared) if @tx.nil?
        res = read_result(@tx.as(DB::Transaction).connection) unless @tx.nil?

        raise "Failed to read data from database" if res.nil?

        res.as(Set)
      end

      protected def read_result(db : DB::Database|DB::Connection)

        set = Set.new

        db.query(@q.as(String)) do |rows|
          rows.each do
            case Topaz::Db.scheme
            when "mysql", "postgres"
              set.push(
                typeof(self).new(
                rows.read(Int32), # id
                {% for key, value in cols %}
                  {% if value.is_a?(NamedTupleLiteral) %}
                    {% if value[:nullable] %}
                      rows.read({{value[:type]}}|Nil),
                    {% else %}
                      rows.read({{value[:type]}}),
                    {% end %}
                  {% else %}
                    rows.read({{value.id}}),
                  {% end %}
                {% end %}
                rows.read(String),
                rows.read(String)
              ))
            when "sqlite3"
              set.push(
                typeof(self).new(
                rows.read(Int64).to_i32, # id
                {% for key, value in cols %}
                  {% if value.is_a?(NamedTupleLiteral) %}
                    {% if value[:nullable] %}
                      rows.read({{value[:type]}}|Nil),
                    {% else %}
                      rows.read({{value[:type]}}),
                    {% end %}
                  {% else %}
                    rows.read({{value.id}}),
                  {% end %}
                {% end %}
                rows.read(String),
                rows.read(String)
              ))
            end
          end
        end unless @q.nil?

        set
      end

      def self.create(
            {% for key, value in cols %}
              {% if value.is_a?(NamedTupleLiteral) %}
                {% if value[:nullable] %}
                  {{key.id}} : {{value[:type]}}|Nil,
                {% else %}
                  {{key.id}} : {{value[:type]}},
                {% end %}
              {% else %}
                {{key.id}} : {{value.id}},
              {% end %}
            {% end %}
          )
        model = new({% for key, value in cols %}{{key.id}},{% end %})
        res = model.save
        model
      end

      def create(
            {% for key, value in cols %}
              {% if value.is_a?(NamedTupleLiteral) %}
                {% if value[:nullable] %}
                  {{key.id}} : {{value[:type]}}|Nil,
                {% else %}
                  {{key.id}} : {{value[:type]}},
                {% end %}
              {% else %}
                {{key.id}} : {{value.id}},
              {% end %}
            {% end %}
          )
        model = typeof(self).new({% for key, value in cols %}{{key.id}},{% end %})
        model.in(@tx.as(DB::Transaction)) unless @tx.nil?
        res = model.save
        model
      end

      def save

        keys = [] of String
        vals = [] of String

        {% for key, value in cols %}
          {% if value.is_a?(NamedTupleLiteral) %}
            {% if value[:nullable] %}
              keys.push("{{key.id}}")
              vals.push("'#{@{{key.id}}}'") unless @{{key.id}}.nil?
              vals.push("null") if @{{key.id}}.nil?
            {% else %}
              keys.push("{{key.id}}") unless @{{key.id}}.nil?
              vals.push("'#{@{{key.id}}}'") unless @{{key.id}}.nil?
            {% end %}
          {% else %}
            keys.push("{{key.id}}") unless @{{key.id}}.nil?
            vals.push("'#{@{{key.id}}}'") unless @{{key.id}}.nil?
          {% end %}
        {% end %}

        time = Time.now

        keys.push("created_at")
        keys.push("updated_at")
        vals.push("\'#{time.to_s(TIME_FORMAT)}\'")
        vals.push("\'#{time.to_s(TIME_FORMAT)}\'")

        _keys = keys.join(", ")
        _vals = vals.join(", ")

        @q = "insert into #{table_name}(#{_keys}) values(#{_vals})"

        res = exec

        @id = res.last_insert_id.to_i32
        # Note: Currently will/crystal-pg doesn't support last_insert_id.to_i32
        if @id == 0 && Topaz::Db.scheme == "postgres"
          @id = typeof(self).select.last.id if @tx.nil?
          @id = typeof(self).in(@tx.as(DB::Transaction)).select.last.id unless @tx.nil?
        end

        @created_at = time
        @updated_at = time

        @q = ""

        self
      end

      def to_a
        [
          ["id", @id],
          {% for key, value in cols %}["{{key.id}}", @{{key.id}}],{% end %}
          ["created_at", "#{@created_at}"],
          ["updated_at", "#{@updated_at}"],
        ]
      end

      def to_h
        {
          "id" => @id,
          {% for key, value in cols %}"{{key.id}}" => @{{key.id}},{% end %}
          "created_at" => "#{@created_at}",
          "updated_at" => "#{@updated_at}",
        }
      end

      def self.create_table

        q = ""

        case Topaz::Db.scheme
        when "mysql"
          q =  <<-QUERY
          create table if not exists #{table_name}(id int auto_increment,
          {% for key, value in cols %}
          {% if value.is_a?(NamedTupleLiteral) %}
          {{key.id}} #{get_type({{value[:type]}})}
          {% if value[:nullable] != nil && value[:nullable] %}
           null
          {% elsif value[:nullable] != nil && !value[:nullable] %}
           not null
          {% end %},
          {% else %}
          {{key.id}} #{get_type({{value.id}})},
          {% end %}{% end %}
          created_at varchar(64),
          updated_at varchar(64),
          index(id));
          QUERY
        when "postgres"
          q =  <<-QUERY
          create table if not exists #{table_name}(id serial
          {% for key, value in cols %}
          {% if value.is_a?(NamedTupleLiteral) %}
          ,{{key.id}} #{get_type({{value[:type]}})}
          {% if value[:nullable] != nil && value[:nullable] %}
           null
          {% elsif value[:nullable] != nil && !value[:nullable] %}
           not null
          {% end %}
          {% else %}
          ,{{key.id}} #{get_type({{value.id}})}
          {% end %}{% end %}
          ,created_at varchar(64)
          ,updated_at varchar(64));
          QUERY
        when "sqlite3"
          q = <<-QUERY
          create table if not exists #{table_name}(id integer primary key
          {% for key, value in cols %}
          {% if value.is_a?(NamedTupleLiteral) %}
          ,{{key.id}} #{get_type({{value[:type]}})}
          {% if value[:nullable] != nil && value[:nullable] %}
           null
          {% elsif value[:nullable] != nil && !value[:nullable] %}
           not null
          {% end %}
          {% else %}
          ,{{key.id}} #{get_type({{value.id}})}
          {% end %}{% end %}
          ,created_at varchar(64)
          ,updated_at varchar(64));
          QUERY
        end

        q = q.gsub("\n", "")
        exec q
      end

      def self.drop_table
        q = "drop table if exists #{table_name}"
        exec q
      end

      protected def self.exec(q)
        new.set_query(q).exec
      end

      protected def exec
        Topaz::Log.q @q.as(String), @tx unless @q.nil?
        res = Topaz::Db.shared.exec @q.as(String) if @tx.nil? && !@q.nil?
        res = @tx.as(DB::Transaction).connection.exec @q.as(String) unless @tx.nil? && !@q.nil?
        raise "Failed to execute \'#{@q}\'" if res.nil?
        res.as(DB::ExecResult)
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
          return "text"
        when "Int32"
          return "int" if Topaz::Db.scheme == "mysql"
          return "integer" if Topaz::Db.scheme == "sqlite3" || Topaz::Db.scheme == "postgres"
        when "Int64"
          return "bigint" if Topaz::Db.scheme == "mysql" || Topaz::Db.scheme == "postgres"
          return "integer" if Topaz::Db.scheme == "sqlite3"
        when "Float32"
          return "float" if Topaz::Db.scheme == "mysql" || Topaz::Db.scheme == "sqlite3"
          return "real" if Topaz::Db.scheme ==  "postgres"
        when "Float64"
          return "double" if Topaz::Db.scheme == "mysql" || Topaz::Db.scheme == "sqlite3"
          return "double precision" if Topaz::Db.scheme == "postgres"
        when "Bool"
          return "tinyint"
        when "Time"
          return "datetime"
        end
      end

      class Set < Array(self)
        # Model set
      end

      {% for key, value in cols %}
        {% if value.is_a?(NamedTupleLiteral) %}
          {% if value[:nullable] %}
            def {{key.id}}=(@{{key.id}} : {{value[:type]}}|Nil)
            end
            def {{key.id}} : {{value[:type]}}|Nil
              return @{{key.id}}.as({{value[:type]}}|Nil)
            end
          {% else %}
            def {{key.id}}=(@{{key.id}} : {{value[:type]}})
            end
            def {{key.id}} : {{value[:type]}}
              return @{{key.id}}.as({{value[:type]}})
            end
          {% end %}
        {% else %}
          def {{key.id}}=(@{{key.id}} : {{value.id}})
          end
          def {{key.id}} : {{value.id}}
            return @{{key.id}}.as({{value.id}})
          end
        {% end %}
      {% end %}
    end

    macro columns(**cols)
      {% if cols.size > 0 %}
        columns({{cols}})
      {% else %}
        columns({} of Symbol => String)
      {% end %}
    end

    macro has_many(models)
      {% for key, value in models %}
        def {{key.id}}
          {{value[:model].id}}.where("{{value[:key].id}} = #{@id}").select
        end
      {% end %}

        def elements(ms : Symbol|String)
          {% if models.size > 0 %}
            case ms
              {% for key, value in models %}
                when :{{key.id}}, "{{key.id}}"
                  return {{key.id}}
              {% end %}
            end
          {% end %}
        end
    end

    macro has_many(**models)
      has_many({{models}})
    end

    def elements(dummy : Symbol | String)
      raise "dummy elements has been called."
    end

    macro belongs_to(models)
      {% for key, value in models %}
        def {{key.id}}
          {{value[:model].id}}.find({{value[:key].id}})
        end
      {% end %}
    end

    macro belongs_to(**models)
      belongs_to({{models}})
    end
  end
end
