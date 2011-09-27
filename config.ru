$:.push '/home/mattgawa/ruby/gems'

require 'rubygems'
require 'sinatra'
require './service'

root_dir = File.dirname(__FILE__)

set :environment, :production
set :root, root_dir
set :app_file, File.join(root_dir, './service.rb')
disable :run

FileUtils.mkdir_p 'log' unless File.exists?('log')
log = File.new("log/sinatra.log", "a")
$stdout.reopen(log)

DB = Sequel.connect(
    :adapter => 'mysql',
    :host => 'mattgawarecki.com',
    :database => 'mattgawa_illyriad',
    :user => 'mattgawa_illy',
    :password => 'Rom4n@Slydr')
IllyriadApi::Service.setDatabase(DB)

def app
    IllyriadApi::Service
end

map '/' do
    run IllyriadApi::Service
end
