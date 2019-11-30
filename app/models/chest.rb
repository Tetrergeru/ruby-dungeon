# frozen_string_literal: true

require 'mongoid'

# Chest
class Chest
  include Mongoid::Document

  field :x, type: Integer
  field :y, type: Integer
  embeds_one :inventory
  embedded_in :level

  def show
    w = 4
    h = (inventory.items.count + w - 1) / w
    r = []
    
    (0..(inventory.items.count - 1)).each do |i|
        r << {x: i % w, y: i / w, name: inventory.items[i].name}
    end

    { width: w, height: h, floor: :chest_bottom, items: r }
  end

  def self.random_generate(x, y)
    c = new(x: x, y: y, inventory: Inventory.new(items: []))
    (0..rand(20)).each do |_|
      c.inventory.items << Item.random_generate
    end
    c
  end
end
