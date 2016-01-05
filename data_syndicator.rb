#!/usr/bin/env ruby
require 'sequel'
require './data_syndicator/core.rb'
ENV['GEM_HOME'] = 'C:Ruby22/lib/ruby/gems/2.2.0/gems/'

DB = Sequel.connect(
   :adapter => 'mysql',
    :host => 'localhost',
    :database => 'database',
    :user => 'user',
    :password => 'password')


start = Time.now

dataSyndicator = IllyriadApi::DataSyndicator.new(DB)
dataSyndicator.run!

DB.disconnect
puts "Elapsed time: #{(Time.now - start).to_s} seconds"
