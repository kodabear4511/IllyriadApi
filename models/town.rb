module IllyriadApi
    class Town < Sequel::Model(:towns)
        #many_to_one :player
        #many_to_one :alliance
    end
end