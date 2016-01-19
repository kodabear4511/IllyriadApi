require 'sequel'
require 'net/http'
require 'open-uri'
require 'xml-object'
begin
    require 'xml-object/adapters/libxml'
rescue LoadError
    puts "LibXML not present, continuing with REXML..."
end


module IllyriadApi
    class DataSyndicator
    private
        @db = nil
        
    public
        def initialize(db = Sequel.sqlite)
            @db = db
        end
        
        def run!
            # Re-create tables
            puts "Creating data tables..."
            createTables!
            
            # Hash of all Illyriad data feeds
            feeds = {
                "towns" => {
                    :action => "parseTownData",
                    :url => "http://bestmagicbears.com/datafiles/datafile_towns.xml" },
                "players" => {
                    :action => "parsePlayerData",
                    :url => "http://bestmagicbears.com/datafiles/datafile_players.xml" },
                 "alliances" => {
                     :action => "parseAllianceData",
                     :url => "http://bestmagicbears.com/datafiles/datafile_alliances.xml" }
            }
            
            # Parse and syndicate each data feed
            feeds.each { |name, hash|
                puts "=== PARSING #{name.upcase} FEED ==="
                start = Time.now
                open(hash[:url]) { |feed|
                    send(hash[:action], feed)
                }
                duration = Time.now - start
                puts "Feed syndication completed in #{duration.to_s} seconds."
                puts
            }
			
            
            # Close DB connection
            puts "Disconnecting"
            @db.disconnect
        end
    
        def parseTownData(xml)
            start = Time.now
			
            townData = XMLObject.new xml
		
            duration = Time.now - start
            
            @db[:feeds].insert(
                :generated_at => townData.server.datagenerationdatetime,
                :type => "Towns",
                :is_current => true)
            
            puts "XML parsed in #{duration.to_s} seconds."
            puts "Towns found: #{townData.towns.count}"
            
            start = Time.now
            townData.towns.each { |town|
                @db[:towns].insert(
                    :data_timestamp => townData.server.datagenerationdatetime,
                    :town_id => town.towndata.townname[:id],
                    :name => town.towndata.townname,
                    :location_x => town.location.mapx,
                    :location_y => town.location.mapy,
                    :founded_at => town.towndata.foundeddatetime,
                    :owner_id => town.player.playername[:id],
                    :population => town.towndata.population,
                    :is_capital => town.towndata.iscapitalcity,
                    :is_alliance_capital => town.towndata.isalliancecapitalcity)
            }
            duration = Time.now - start
            puts "Database populated in #{duration.to_s} seconds."
            
            puts "Logging town deltas..."
            start = Time.now
            feedTimestamp = DateTime.parse(townData.server.datagenerationdatetime)
            logTownDeltas!(feedTimestamp)
            duration = Time.now - start
            puts "Town deltas logged in #{duration.to_s} seconds."
        end
        
def logTownDeltas!(newDate)
						
            deltas = []
        	old = @db[:towns].filter {data_timestamp < newData } was added to that code
currentTowns = @db[:towns].filter { data_timestamp >= newDate }

  destroyedTownIDs = @db[:towns].select(:town_id).filter { data_timestamp < newDate }.collect { |d| d[:town_id] }
  createdTownIDs = @db[:towns].select(:town_id).filter { data_timestamp >= newDate }.collect { |c| c[:town_id] }
            
            alteredTowns = Hash.new
            currentTowns.each { |town|
                
            }
            
            destroyedTownIDs.each { |d|
                t = oldTowns.filter(:town_id => d).first
                @db[:town_deltas].insert(
                    :happened_at => newDate,
                    :town_id => d,
                    :owner_id => t[:owner_id],
                    :name => t[:name],
                    :population => 0,
                    :is_capital => 0,
                    :is_alliance_capital => 0)
            }
            	

            createdTownIDs.each { |c|
                t = currentTowns.filter(:town_id => c).first
                @db[:town_deltas].insert(
                    :happened_at => newDate,
                    :town_id => c,
                    :owner_id => t[:owner_id],
                    :name => t[:name],
                    :population => t[:population],
                    :is_capital => t[:is_capital],
                    :is_alliance_capital => t[:is_alliance_capital])
            }
            			
            

            # Delete old data, it's not needed anymore
            @db[:towns].filter{ data_timestamp < newDate }.delete
        end
        
        def parsePlayerData(xml)
            start = Time.now
            playerData = XMLObject.new xml
            duration = Time.now - start
            
            puts "XML parsed in #{duration.to_s} seconds."
            puts "Players found: #{playerData.players.count}"
            
            @db[:feeds].insert(
                :generated_at => playerData.server.datagenerationdatetime,
                :type => "Players",
                :is_current => true)
            
            start = Time.now
            playerData.players.each { |player|
                alliance_id = (player.allianceid[:id] == "0" ? nil : player.allianceid[:id])
                alliance_role_id = (alliance_id.nil? ? nil : player.allianceroleid[:id])
            
                @db[:players].insert(
                    :id => player.playername[:id],
                    :name => player.playername,
                    :race_id => player.race[:id],
                    :alliance_id => alliance_id,
                    :alliance_role_id => alliance_role_id)
            }
            duration = Time.now - start
            puts "Database populated in #{duration.to_s} seconds."
        end
        
        def parseAllianceData(xml)
            start = Time.now
            allianceData = XMLObject.new xml
            duration = Time.now - start
            
            puts "XML parsed in #{duration.to_s} seconds."
            puts "Alliances found: #{allianceData.alliances.count}"
            
            @db[:feeds].insert(
                :generated_at => allianceData.server.datagenerationdatetime,
                :type => "Alliances",
                :is_current => true)
            
            start = Time.now
            allianceData.alliances.each { |alliance|
                capital_last_moved_at = (alliance.alliancecapitallastmoved rescue nil)
                taxrate_last_changed_at = (alliance.alliancetaxratelastchanged rescue nil)
                @db[:alliances].insert(
                    :id => alliance.alliance[:id],
                    :ticker => alliance.allianceticker,
                    :name => alliance.alliance,
                    :founded_at => alliance.foundeddatetime,
                    :founded_by_player_id => alliance.foundedbyplayerid[:id],
                    :capital_town_id => alliance.alliancecapitaltownid[:id],
                    :member_count => alliance.membercount,
                    :total_population => (alliance.totalpopulation rescue 0),
                    :tax_rate => (alliance.alliancetaxrate.to_i) / 100.0,
                    :tax_rate_last_changed_at => taxrate_last_changed_at,
                    :capital_town_last_moved_at => capital_last_moved_at)
            
                alliance.roles.each { |role|
                    @db[:alliance_roles].insert(
                        :id => role.role[:id],
                        :name => role.role,
                        :alliance_id => alliance.alliance[:id],
                        :hierarchy_id => role.heirarchy[:id])
                }
            }
            duration = Time.now - start
            puts "Database populated in #{duration.to_s} seconds."
        end
		
        
        def createTables!
            if @db.table_exists? :feeds
                puts "Feeds (*already created)"
                @db[:feeds].update(:is_current => false)
            else
                puts "Feeds"
                @db.create_table :feeds do
                    primary_key :id
                    DateTime :generated_at, :index => true
                    String :type, :index => true
                    TrueClass :is_current
                end
            end
        
            if @db.table_exists? :towns
                puts "Towns (*already created)"
            else
                puts "Towns"
                @db.create_table :towns do
                    primary_key :id
                    DateTime :data_timestamp
                    Integer :town_id, :index => true
                    String :name, :index => true
                    Integer :location_x
                    Integer :location_y
                    DateTime :founded_at
                    Integer :owner_id, :index => true
                    Integer :population
                    TrueClass :is_capital
                    TrueClass :is_alliance_capital
                end
            end
            
            if @db.table_exists? :town_deltas
                puts "Town Deltas (*already created)"
            else
                puts "Town Deltas"
                @db.create_table :town_deltas do
                    primary_key :id
                    DateTime :happened_at
                    Integer :town_id, :index => true
                    Integer :owner_id, :index => true
                    String :name, :index => true
                    Integer :population
                    TrueClass :is_capital
                    TrueClass :is_alliance_capital
                end
            end
            
            if @db.table_exists? :races
                puts "Races (*already created)" 
            else
                puts "Races"
                @db.create_table :races do
                    Integer :id, :primary_key => true
                    String :name, :index => true
                end
                
                @db[:races].multi_insert([
                    {:id => 1, :name => "Human"},
                    {:id => 2, :name => "Elf"},
                    {:id => 3, :name => "Dwarf"},
                    {:id => 4, :name => "Orc"}])
            end
            if @db.table_exists? :players
                puts "player (*already created)"
				else
            puts "Players"
            @db.create_table! :players do
                Integer :id, :primary_key => true
                foreign_key :race_id, :races
                Integer :alliance_id, :null => true
                Integer :alliance_role_id, :null => true
                String :name, :index => true
            end
			end
		if @db.table_exists? :alliances
                puts "alliances (*already created)"
				else
               puts "Alliances"

            @db.create_table! :alliances do
                Integer :id, :primary_key => true
		        String :ticker, :index => true
                String :name, :index => true
                DateTime :founded_at
                Integer :founded_by_player_id
                Integer :capital_town_id
                Integer :member_count
                Integer :total_population
                BigDecimal :tax_rate, :size => [5, 3]
                DateTime :tax_rate_last_changed_at, :null => true
                DateTime :capital_town_last_moved_at, :null => true
            end
end
			if @db.table_exists? :alliance_roles
                puts "alliances (*already created)"
				else
            puts "Alliance Roles"
            @db.create_table! :alliance_roles do
                Integer :id, :primary_key => true
                String :name, :index => true
                foreign_key :alliance_id, :alliances
                Integer :hierarchy_id
            end
            
         end
            
            #addForeignKeys!
        end
        
        private
        def addForeignKeys!
            @db.alter_table(:alliances) do
                add_foreign_key [:founded_by_player_id], :players
                add_foreign_key [:capital_town_id], :towns
            end
            
            @db.alter_table(:players) do
                add_foreign_key [:alliance_id], :alliances
                add_foreign_key [:alliance_role_id], :alliance_roles
            end
            
            @db.alter_table(:towns) do
                add_foreign_key [:owner_id], :players
            end
        end
    end
end
