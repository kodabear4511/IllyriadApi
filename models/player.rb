module IllyriadApi
    class Player < Sequel::Model(:players)
        many_to_one :race
        one_to_many :towns, :key => :owner_id
        many_to_one :alliance
        many_to_one :alliance_role
    end
end