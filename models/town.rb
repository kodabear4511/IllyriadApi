module IllyriadApi
    class Town < Sequel::Model(:towns)
        many_to_one :owner, :class => Player
    end
end