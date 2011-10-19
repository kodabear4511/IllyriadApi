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
        helpers do
            def serialize(data, format)
                if format.upcase == "XML"
                    classname = data.class.name.split('::').last.downcase
                    if classname.upcase == "ARRAY"
                        classname = data.first.class.name.split('::').last.downcase
                        data.to_xml(:root_name => classname, :array_root_name => classname + "s")
                    else
                        data.to_xml(:root_name => classname)
                    end
                elsif format.upcase == "JSON"
                    data.to_json
                else
                    not_found
                end
            end
        end
        
        def self.setDatabase(db = Sequel.connect("sqlite://illy.sqlite"))
            @@db ||= db

            Sequel::Model.db = @@db
            Sequel::Model.plugin :xml_serializer
            Sequel::Model.plugin :json_serializer
            
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
        get %r(/alliances/id/([1-9]\d*).(xml|json)) do |id, format|
            a = Alliance[id]
            
            if a.nil?
                not_found
            else
                serialize(a, format)
            end
        end
        
        get %r(/alliances/ticker/(.+).(xml|json)) do |ticker, format|
            a = Alliance.filter(:ticker => ticker)
            
            if a.nil?
                not_found
            else
                serialize(a, format)
            end
        end
        
        get %r(/alliances/name/(.+).(xml|json)) do |name, format|
            a = Alliance.filter(:name => name)
            
            if a.nil?
                not_found
            else
                serialize(a, format)
            end
        end
        
        # Players        
        get %r{/players/id/([1-9]\d*).(xml|json)} do |id, format|
            p = Player[id]
            
            if p.nil?
                not_found
            else
                serialize(p, format)
            end
        end
        
        get %r{/players/name/(.{3,}).(xml|json)} do |name, format|
            p = Player.filter(:name => name)
            
            if p.nil?
                not_found
            else
                serialize(p, format)
            end
        end
        
        get %r{/players/id/([1-9]\d*)/towns\.(xml|json)} do |id, format|
            p = Player[id]
            
            if p.nil?
                not_found
            else
                serialize(Town.filter(:owner => p), format)
            end
        end
        
        get %r{/players/name/(.{3,})/towns\.(xml|json)} do |name, format|
            p = Player.filter(:name => name).first
            
            if p.nil?
                not_found
            else
                serialize(Town.filter(:owner => p), format)
            end
        end
        
        # Towns        
        get %r{/towns/id/([1-9]\d*).(xml|json)} do |id, format|
            t = Town[id]
            
            if t == nil
                not_found
            else
                serialize(t, format)
            end
        end
        
        get %r{/towns/name/(.+).(xml|json)} do |name, format|
            t = Town.filter(:name => name)
            if t == nil
                not_found
            else
                serialize(t, format)
            end
        end
        
        # Map
        # get %r{/map/(^-?\d{1,3}$)/(^-?\d{1,3}$)} do |x, y|
            # "Get map square (#{x}, #{y})"
        # end
    end
end