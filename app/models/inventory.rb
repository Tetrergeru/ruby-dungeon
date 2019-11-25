require 'mongoid'

# Inventory
class Inventory
    include Mongoid::Document
    
    embeds_many :items
    embedded_in :owner
end