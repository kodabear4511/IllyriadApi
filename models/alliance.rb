class Alliance < Sequel::Model(:alliances)
    one_to_many :players
    one_to_many :towns
end