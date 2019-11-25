require 'mongoid'

# Chest
class Chest
    include Mongoid::Document

    embeds_one :inventory
    embedded_in :level
end