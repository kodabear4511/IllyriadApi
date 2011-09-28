module IllyriadApi
    class Alliance < Sequel::Model(:alliances)
        one_to_many :players
        many_to_one :founder, :class => Player, :key => :founded_by_player_id
        one_to_one :capital, :class => Town, :key => :capital_town_id
        
        def getAllTowns
            towns = []
            self.players.each do |p| towns.push(p.towns) end
            
            towns
        end
    end
end