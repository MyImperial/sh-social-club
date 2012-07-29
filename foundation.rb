require 'rubygems'
require 'digest'
require 'data_mapper'
require 'sinatra'
require 'mysql2'
require 'yaml'

FileUtils.rm_rf("recall.db")

# load the config and setup the authentication
DEFAULT_CONFIG = 'config.yml'
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

# define the schema for the tables

class TotalIncome
  include DataMapper::Resource
  property :id, Serial
  property :title, String, :required => true               # default length limit of 50 characters
  property :amount, Decimal, :required => true, :scale => 2, :default => 1
  property :created_at, DateTime
  property :updated_at, DateTime
end

class Note
  include DataMapper::Resource
  property :id, Serial
  property :content, Text, :required => true
  property :complete, Boolean, :required => true, :default => 0
  property :created_at, DateTime
  property :updated_at, DateTime
end


class IndividualContribution
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :required => true
  property :amount, Decimal, :required => true
  property :created_at, DateTime
  property :updated_at, DateTime
end

class Comments
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :content, Text, :required => true
  property :created_at, DateTime
end

DataMapper.auto_upgrade!

# the rest api here
get '/' do
  erb :home
end

get '/accounts' do
  erb :accounts
end

get '/accounts/total_income' do
  @income = TotalIncome.all :order => :id.asc
  erb :total_income
end

get '/accounts/individual_contribution' do
  erb :individual_contribution
end

get '/highlights' do
  erb :highlights
end

get '/contact' do
  erb :contact
end

get '/admin/total_income' do
  erb :admin_total_income
end

post '/admin_total_income' do
  new_income = TotalIncome.new
  new_income.title = params[:title]
  new_income.amount = params[:amount]
  new_income.created_at = Time.now
  new_income.updated_at = Time.now
  unless new_income.save
    new_income.errors.each do |error|
      puts error
    end
  end
  redirect '/accounts/total_income'
end

=begin
post '/' do
  n = Note.new
  n.content = params[:content]
  n.created_at = Time.now
  n.updated_at = Time.now
  n.save
  redirect '/'
end

get '/:id' do
  @note = Note.get params[:id]
  @title = "Edit note ##{params[:id]}"
  erb :edit
end

put '/:id' do
  n = Note.get params[:id]
  n.content = params[:content]
  n.complete = params[:complete] ? 1 : 0
  n.updated_at = Time.now
  n.save
  redirect '/'
end

get '/:id/delete' do
  @note = Note.get params[:id]
  @title = "Confirm deletion of note ##{params[:id]}"
  erb :delete
end

delete '/:id' do
  n = Note.get params[:id]
  n.destroy
  redirect '/'
end

get '/:id/complete' do
  n = Note.get params[:id]
  n.complete = n.complete ? 0 : 1 # flip it
  n.updated_at = Time.now
  n.save
  redirect '/'
end
=end
