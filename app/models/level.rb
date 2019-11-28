require 'mongoid'

# Level
class Level
    include Mongoid::Document
    field :width, type: Integer
    field :height, type: Integer
    
    embeds_many :chests
    embeds_many :monsters
    embeds_many :walls

    def show
        r = []

        chests.all.each do |c|
            r << {id: c.id.to_s, x: c.x, y: c.y, name: :chest}
        end

        monsters.all.each do |c|
            r << {id: c.id.to_s, x: c.x, y: c.y, name: :monster}
        end

        walls.all.each do |c|
            r << {x: c.x, y: c.y, name: :wall}
        end

        {width: width, height: height, floor: :floor, items: r}
    end

    def self.random_generate
        l = create(width: rand(10) + 5, height: rand(10) + 5)
        
        for i in 0..(l.width - 1)
            for j in 0..(l.height - 1)
                case rand(10)
                when 0
                    l.chests << Chest.new(x: i, y: j)
                when 1
                    l.monsters << Monster.new(x: i, y: j)
                when 2
                    l.walls << Wall.new(x: i, y: j)
                end
            end
        end
        l.id.to_s
    end
end