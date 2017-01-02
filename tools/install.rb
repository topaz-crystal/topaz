#!/usr/bin/ruby

require "net/http"
require "uri"
require "open3"
require "yaml"
require "fileutils"

makefile = <<-MAKEFILE

MODELS = src/models/*.cr

setup: $(wildcard MODELS)
\tcrystal deps
\tcrystal run src/utils/setup.cr

migration: $(wildcard MODELS)
\tcrystal run src/utils/migration.cr

debug: src/$PROJNAME$.cr
\tcrystal build src/$PROJNAME$.cr -o bin/server

release: src/$PROJNAME$.cr
\tcrystal build src/$PROJNAME$.cr --release -o bin/server

run:
\tbin/server

clean:
\trm -rf shard.lock
\trm -rf lib
\trm -rf .shards

help:
\tprintf "\\
\t[Help] Topaz with Kemal \\n\\
\t\\n\\
\t> make setup \\n\\
\t  Setup the project (Create tables) \\n\\
\t  Call this first after create the project or add tables \\n\\
\t\\n\\
\t> make migration \\n\\
\t  Migrate tables, execute when you add/remove columns to/from defined tables \\n\\
\t\\n\\
\t> make debug \\n\\
\t  Debug build the project \\n\\
\t\\n\\
\t> make release \\n\\
\t  Release build the project \\n\\
\t\\n\\
\t> make run \\n\\
\t  Start Kemal server \\n\\
\t\\n\\
\t> make clean \\n\\
\t  Clean project \\n\\
\t\\n\\
\t> make help -s \\n\\
\t  Show this help \\n\\
\t\\n"
MAKEFILE

sample_cr = <<-SAMPLE
require "topaz"

class Sample < Topaz::Model
    columns(
        name: String
    )
end
SAMPLE

setup_cr = <<-SETUP
require "../models/*"
Topaz::Db.setup("$DB$")
Sample.create_table
SETUP

migration_cr = <<-MIGRATION
require "../models/*"
Topaz::Db.setup("$DB$")
Sample.migrate_table
MIGRATION

index_ecr = <<-INDEX
<ul>
<% samples.each do |sample| %>
<li><%= sample.name %></li>
<% end %>
</ul>
INDEX

layout_ecr = <<-LAYOUT
<!DOCTYPE html>
<html>
  <head>
    <!-- HTML Header -->
  </head>
  <body>
    <div>
      <p>Welcome Topaz x Kemal!</p>
      <form action="/" method="get">
	<input type="text" name="name" size="20" />
	<input type="submit" value="Submit" />
      </form>
      <%= content %>
    </div>
  </body>
</html>
LAYOUT

server_cr = <<-SERVER
require "./$PROJNAME$/*"
require "./models/*"
require "kemal"
require "topaz"

class WebServer
  def initialize(@port = 3000)
  end

  def self.render_samples
    samples = Sample.select
    render "src/views/index.ecr", "src/views/layout.ecr"
  end

  get "/" do |env|
    name = env.params.query["name"] if env.params.query.has_key?("name")
    Sample.create("\#{name}") unless name.nil?
    render_samples
  end

  def run
    Kemal.run(@port)
  end
end

Topaz::Db.setup("$DB$")
Topaz::Db.show_query(true)

server = WebServer.new
server.run
SERVER

LOG = "\e[32m[Topaz x Kemal]\e[0m "

def log msg
  puts "#{LOG}#{msg}"
end

def cursor
  print "> "
end

def tag t
  "$#{t}$"
end

def command_check
  log "Command check ..."
  log "Passed!"
end

def exec_cmd cmd
  res = Open3.capture3 cmd
  puts res[0]
end

def input description, example = nil, default = nil

  result = ""

  while result.empty?
    log description
    log "e.g.   : #{example}" unless example.nil?
    log "default: #{default}" unless default.nil?
    cursor
    result = gets.chop
    result = default if result.empty? && !default.nil?
  end

  result
end

def shard_yml_update
  shard_yml = YAML.load_file "shard.yml"
  shard_yml["dependencies"] = {}
  shard_yml["dependencies"]["kemal"] = {}
  shard_yml["dependencies"]["kemal"]["github"] = "kemalcr/kemal"
  shard_yml["dependencies"]["topaz"] = {}
  shard_yml["dependencies"]["topaz"]["github"] = "topaz-crystal/topaz"

  File.delete "shard.yml"
  YAML.dump shard_yml, File.open("shard.yml", "w")
end

def add_file filename, contents
  open filename, "w" do |file|
    file.write(contents)
  end
  log "Added #{filename}"
end

command_check

project_name = input "Project Name?"
install_dir  = input "Installed Dir?" # Should default
database     = input "Which database do you use?",
                     "mysql://root@localhost/mydatabase",
                     "sqlite3://./db/default.db"

Dir.chdir install_dir do
  
  exec_cmd "crystal init app #{project_name}"
  
  Dir.chdir project_name do
    
    log "Constructing project..."
    
    shard_yml_update

    FileUtils.rm "src/#{project_name}.cr"
    
    Dir.mkdir "bin"
    Dir.mkdir "db"
    Dir.mkdir "src/models"
    Dir.mkdir "src/views"
    Dir.mkdir "src/utils"

    add_file "Makefile",
             makefile.gsub(tag("PROJNAME"), project_name)

    add_file "src/models/sample.cr",
             sample_cr.gsub(tag("DB"), database)

    add_file "src/utils/setup.cr",
             setup_cr.gsub(tag("DB"), database)

    add_file "src/utils/migration.cr",
             migration_cr.gsub(tag("DB"), database)

    add_file "src/views/index.ecr",
             index_ecr

    add_file "src/views/layout.ecr",
             layout_ecr

    add_file "src/#{project_name}.cr",
             server_cr.gsub(tag("PROJNAME"), project_name).gsub(tag("DB"), database)

    exec_cmd "make help -s"
  end
end

log "Execute `make setup` to start #{install_dir}/#{project_name}"
