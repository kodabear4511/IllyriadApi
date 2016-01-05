require 'rubygems'
require 'sinatra'
require './service'
require 'pry'


root_dir = File.dirname(__FILE__)

set :environment, :production
set :root, root_dir
set :app_file, File.join(root_dir, './service.rb')


FileUtils.mkdir_p 'log' unless File.exists?('log')
log = File.new("log/sinatra.log", "a")
$stdout.reopen(log)

DB = Sequel.connect(
    :adapter => 'mysql',
    :host => 'host',
    :database => 'database',
    :user => 'user',
    :password => 'password')
IllyriadAp::Service.setDatabase(DB)
run IllyriadAp::Service
def app
    IllyriadAp::Service
end

map '/' do
    run IllyriadAp::Service
end
map '/' do
    run IllyriadApi::Service
end
