require 'mongoid'

# Level
class Level
    include Mongoid::Document
    field :width, type: Integer
    field :height, type: Integer
    
    embeds_many :chests

    def show
        check = []
        r = []

        chests.all.each do |c|
            r << {id: c.id.to_s, x: c.x, y: c.y, name: 'chest'}
            check << c.x + c.y * width
        end

        for i in 0..(width - 1)
            for j in 0..(height - 1)
                if !check.include?(i + j * width)
                    r << {x: i, y: j, name: 'floor'}
                end
            end
        end
        {width: width, height: height, items: r}
    end
end