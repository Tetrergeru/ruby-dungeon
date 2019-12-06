# frozen_string_literal: true

require 'mongoid'

# Chest
class Chest
  include Mongoid::Document

  field :x, type: Integer
  field :y, type: Integer
  embeds_one :inventory
  embedded_in :level

  def show(user)
    c_items = inventory.items
    u_items = user.inventory.items

    w = 6
    h = 40 / w
    r = [{ x: 0, y: 0, name: :back, id: 'back' }]

    (0..(c_items.count - 1)).each do |i|
      r << { x: i % w + w + 1, y: i / w + 1, name: c_items[i].name, id: c_items[i].id.to_s }
    end

    (0..(u_items.count - 1)).each do |i|
      r << { x: i % w, y: i / w + 1, name: u_items[i].name, id: u_items[i].id.to_s }
    end

    (1..(h - 1)).each do |i|
      r << { x: w, y: i, name: 'chest_separator' }
    end

    (w..(2 * w)).each do |i|
      r << { x: i, y: 0, name: 'chest_up_separator' }
    end

    { width: w * 2 + 1, height: h, floor: :chest_bottom, wall: :chest_wall, items: r }
  end

  def action(user, action_id)
    if action_id == 'back'
      $redis_action.del(user.id)
      return
    end

    c_items = inventory.items
    u_items = user.inventory.items

    if c_items.any? { |i| i.id.to_s == action_id }
      item = c_items.find(action_id)
      u_items << item.clone
      c_items.delete(item)
      return
    end

    if u_items.any? { |i| i.id.to_s == action_id }
      item = u_items.find(action_id)
      c_items << item.clone
      u_items.delete(item)
      nil
    end
  end

  def self.random_generate(x, y)
    c = new(x: x, y: y, inventory: Inventory.new(items: []))
    (0..rand(20)).each do |_|
      c.inventory.items << Item.random_generate
    end
    c
  end
end
