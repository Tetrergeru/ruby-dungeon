require 'mongoid'

# Level
class Level
    include Mongoid::Document
    
    embeds_many :chests
end