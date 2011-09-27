$:.push '/home/mattgawa/ruby/gems'

# Ruby files
require 'rubygems'
require 'sinatra/base'
require 'sequel'

module IllyriadApi
    # class ServiceConfig
        # private
        # @connection_string = nil
        
        # public
        # begin
            # require 'psych'
        # rescue LoadError
            # Can't find the psych library
        # end
        # require 'yaml'
        
        # def load(filePath)
            # YAML::load(filePath)
        # end
    # end

    class Service < Sinatra::Base
    private
        @@db = nil
        
    public        
        def self.setDatabase(db = Sequel.connect("sqlite://illy.sqlite"))
            @@db ||= db

            Sequel::Model.db = @@db
            Sequel::Model.plugin :xml_serializer
            
            # Load IllyriadApi data models
            require './data_models'
        end
        
        def self.run!
            
            self.setDatabase
            super
        end
    
        # Application route handling
        # 404
        not_found do
            "This is not the page you're looking for."
        end
        
        # Errors
        # error do
            # "There was an error!"
        # end
        
        # Testing
        # get '/' do
            # raise "something bad happened"
        # end
        
        # Alliances
        # get '/alliances' do
            # "Get ALL alliances"
        # end
        
        # get %r(/alliances/id/([1-9]\d*)) do |id|
            # "Get alliance ##{id}"
        # end
        
        # get %r(/alliances/ticker/(.+)) do |ticker|
            # "Get alliance with ticker '#{ticker}'"
        # end
        
        # get %r(/alliances/name/(.+)) do |name|
            # "Get alliance named '#{name}'"
        # end
        
        # Players
        # get '/players' do
            # "Get ALL players"
        # end
        
        # get %r{/players/id/([1-9]\d*)} do |id|
            # "Get player ##{id}"
        # end
        
        # get %r{/players/name/(.{3,})} do |name|
            # "Get player named '#{name}'"
        # end
        
        # Towns
        get '/towns' do
            t = Town.all
            if t == nil
                not_found
            else
                t.to_xml(:array_root_name => "towns", :root_name => "town")
            end
        end
        
        get %r{/towns/id/([1-9]\d*)} do |id|
            t = Town[id]
            
            if t == nil
                not_found
            else
                t.to_xml(:root_name => "town")
            end
        end
        
        get %r{/towns/name/(.+)} do |name|
            t = Town.filter(:name => name)
            if t == nil
                not_found
            else
                t.to_xml(:array_root_name => "towns", :root_name => "town")
            end
        end
        
        # Map
        # get %r{/map/(^-?\d{1,3}$)/(^-?\d{1,3}$)} do |x, y|
            # "Get map square (#{x}, #{y})"
        # end
    end
end