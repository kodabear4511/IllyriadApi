#!/usr/bin/env ruby
ENV['GEM_HOME'] = '/home/mattgawa/ruby/gems'

require 'sequel'
require './scripts/data_syndicator/core.rb'

DB = Sequel.connect(
    :adapter => 'mysql',
    :host => 'localhost',
    :database => 'mattgawa_illyriad',
    :user => 'mattgawa_illy',
    :password => 'Rom4n@Slydr')

start = Time.now

dataSyndicator = IllyriadApi::DataSyndicator.new(DB)
dataSyndicator.run!

DB.disconnect
puts "Elapsed time: #{(Time.now - start).to_s} seconds"