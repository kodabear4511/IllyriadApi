module IllyriadApi
    class AllianceRole < Sequel::Model(:alliance_roles)
        many_to_one :alliance
        one_to_many :players
    end
end