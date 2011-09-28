module IllyriadApi
    class Race < Sequel::Model(:races)
        one_to_many :players
    end
end