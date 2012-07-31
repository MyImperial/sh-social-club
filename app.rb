require 'rubygems'
require 'digest'
require 'data_mapper'
require 'sinatra'
require 'mysql2'
require 'yaml'

FileUtils.rm_rf("recall.db")

# load the config and setup the authentication
DEFAULT_CONFIG = 'foundation.yml'
config_file = File.join(File.dirname(__FILE__), DEFAULT_CONFIG)

begin
  config = File.open(config_file) { |f| YAML.load(f) }
rescue => e
  STDERR.puts "cannot load the configuration file: #{e}"
  exit
end

FileUtils.rm_rf(config_file) if ENV['VCAP_APPLICATION']
use Rack::Auth::Basic do |username, password|
  username = Digest::SHA1.hexdigest(username)
  password = Digest::SHA1.hexdigest(password)
  [username, password] == [config['auth']['user'], config['auth']['pass']]
end

=begin
# load the mysql service
def load_service(service_name)
  services = JSON.parse(ENV['VMC_SERVICES'])
  service = services.find {|service| service["vendor"].downcase == service_name}
  service = service["options"] if service
end

def load_mysql
  mysql_service = load_service('mysql')
  username = mysql_service['user']
  password = mysql_service['password']
  hostname = mysql_service['hostname']
  port     = mysql_service['port']
  database = mysql_service['name']
  DataMapper::setup(:default, 'mysql://username:passwprd@hostname:port/database')
end
=end

DataMapper::Logger.new($stdout, :debug)
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/recall.db")

class Foundation < Sinatra::Application
  enable :sessions
end

Foundation.new

require_relative 'models/init'
require_relative 'helpers/init'
require_relative 'routes/init'
