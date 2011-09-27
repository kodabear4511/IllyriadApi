class Player < Sequel::Model(:players)
    one_to_many :towns
    one_to_one :alliance
end