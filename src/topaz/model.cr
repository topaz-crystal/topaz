require "mysql"
require "sqlite3"

module Topaz
  class Model
    macro columns(*cols)
      def initialize(
            {% for ch in cols %}
              {% if ch[:name] != nil %}
                @{{ch[:name]}} : {{ch[:type]}}|Nil,
              {% end %}
            {% end %}@q = "")
      end

      protected def initialize(
            @id : Int32 | Nil,
            {% for ch in cols %}
              {% if ch[:name] != nil %}
                @{{ch[:name]}} : {{ch[:type]}}|Nil,
              {% end %}
            {% end %}@q = "")
      end

      protected def initialize
        {% for ch in cols %}
          {% if ch[:name] != nil %}
            @{{ch[:name]}} = nil
          {% end %}
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
          data = { {% for ch in cols %}{% if ch[:name] != nil %}{{ch[:name]}}: @{{ch[:name]}},{% end %}{% end %} }
          update(data)
        {% end %}
      end

      def select
        
        @q = "select * from #{table_name} #{@q}"
        Topaz::Logger.q @q
        
        set = Array(typeof(self)).new
        
        DB.open Topaz.env do |db|
          db.query(@q) do |res|
            res.each do
              case Topaz.db
              when :mysql
                set.push(
                  typeof(self).new(
                  res.read(Int32), # id
                  {% for ch in cols %}
                    {% if ch[:name] != nil %}
                      res.read({{ch[:type]}}|Nil),
                    {% end %}
                  {% end %}
                ))
              when :sqlite3
                set.push(
                  typeof(self).new(
                  res.read(Int64).to_i32, # id
                  {% for ch in cols %}
                    {% if ch[:name] != nil %}
                      res.read({{ch[:type]}}|Nil),
                    {% end %}
                  {% end %}
                ))
              end
            end
          end
        end
        
        set
      end
      
      def self.create({% for ch in cols %}{% if ch[:name] != nil %}{{ch[:name]}} : {{ch[:type]}}|Nil,{% end %}{% end %})
        model = new({% for ch in cols %}{% if ch[:name] != nil %}{{ch[:name]}},{% end %}{% end %})
        res = model.save
        model
      end
      
      def save

        keys = [] of String
        vals = [] of String

        {% for ch in cols %}
          {% if ch[:name] != nil %}
            keys.push("{{ch[:name]}}") unless @{{ch[:name]}}.nil?
            vals.push("'#{@{{ch[:name]}}}'") unless @{{ch[:name]}}.nil?
          {% end %}
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
          {% for ch in cols %}{% if ch[:name] != nil %}["{{ch[:name]}}", @{{ch[:name]}}],{% end %}{% end %}
        ]
      end
      
      def to_h
        {
          "id" => @id,
          {% for ch in cols %}{% if ch[:name] != nil %}"{{ch[:name]}}" => @{{ch[:name]}},{% end %}{% end %}
        }
      end
      
      def value_of(key : String)
        case key
        when "id"
          @id
          {% for ch in cols %}
            {% if ch[:name] != nil %}
            when "{{ch[:name]}}"
              @{{ch[:name]}}
            {% end %}
          {% end %}
        end
      end
      
      def set_value_of(key : String, value : DB::Any)
        {% if cols.size > 0%}
          case key
              {% for ch in cols %}
                {% if ch[:name] != nil %}
                when "{{ch[:name]}}"
                  @{{ch[:name]}} = value
                {% end %}
              {% end %}
          end
        {% end %}
      end
      
      def self.create_table
        
        case Topaz.db
        when :mysql
          query = "create table if not exists #{table_name}(id int auto_increment,{% for ch in cols %}{% if ch[:name] != nil %}{{ch[:name]}} #{get_type({{ch[:type]}})}{% if !ch[:primary].nil? && ch[:primary] %} primary key{% end %},{% end %}{% end %}index(id))"
        when :sqlite3
          query = "create table if not exists #{table_name}(id integer primary key,{% for ch, idx in cols %}{% if ch[:name] != nil %}{{ch[:name]}} #{get_type({{ch[:type]}})}{% if !ch[:primary].nil? && ch[:primary] %} primary key{% end %}{% if idx != cols.size-1 %},{% end %}{% end %}{% end %})"
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
        Topaz::Logger.q @q
        DB.open Topaz.env do |db|
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

      def self.parent_id(model)
        {% if cols.size > 0 %}
          {% for ch in cols %}
            {% if ch[:belongs] != nil %}
              if model == {{ch[:belongs]}}
                "{{ch[:name]}}"
              end
            {% end %}
          {% end %}
        {% end %}
      end

      private def self.get_type(t)
        case t.to_s
        when "String"
          "text"
        when "Int32"
          return "int" if Topaz.db == :mysql
          return "integer" if Topaz.db == :sqlite3
        when "Int64"
          return "int" if Topaz.db == :mysql
          return "integer" if Topaz.db == :sqlite3
        when "Float32"
          "float"
        when "Float64"
          "double"
        end
      end
      
      {% for ch in cols %}
        {% if ch[:name] != nil %}
          def {{ch[:name]}}=(@{{ch[:name]}} : {{ch[:type]}})
          end

          def {{ch[:name]}}
            return @{{ch[:name]}}
          end

          {% if ch[:belongs] != nil%}
            def {{ch[:as]}}
              {{ch[:belongs]}}.find(@{{ch[:name]}})
            end
          {% end %}
        {% end %}
          {% if ch[:has] != nil %}
            def {{ch[:as]}}
              p_id = {{ch[:has]}}.parent_id(typeof(self))
              {{ch[:has]}}.where("#{p_id} = '#{@id}'").select
            end
          {% end %}
      {% end %}
    end
  end
end
