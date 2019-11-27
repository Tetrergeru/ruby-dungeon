require 'mongoid'

# Chest
class Chest
    include Mongoid::Document

    field :x, type: Integer
    field :y, type: Integer
    embeds_one :inventory
    embedded_in :level
end