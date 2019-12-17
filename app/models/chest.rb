# frozen_string_literal: true

require 'mongoid'

# Chest
class Chest
  include Mongoid::Document

  field :x, type: Integer
  field :y, type: Integer
  embeds_one :inventory
  embedded_in :level

  def self.show(id, user_id, user_hash)
    chest = State.load(id)
    if !chest
      chest = Level.find(User.find(user_id).location).chests.find(id).abstract_show
      State.update(id, chest)
      chest = chest.to_json
    end
    Chest.add_user(JSON.load(chest), user_hash)
  end

  def abstract_show
    c_items = inventory.items

    w = 6
    h = 40 / w
    r = [{ x: 0, y: 0, name: :back, id: 'back' }]

    (0..(c_items.count - 1)).each do |i|
      r << { x: i % w + w + 1, y: i / w + 1, name: c_items[i].name, id: c_items[i].id.to_s }
    end

    (1..(h - 1)).each do |i|
      r << { x: w, y: i, name: 'chest_separator' }
    end

    (w..(2 * w)).each do |i|
      r << { x: i, y: 0, name: 'chest_up_separator' }
    end

    { width: w * 2 + 1, height: h, floor: :chest_bottom, wall: :chest_wall, items: r }
  end

  def self.add_user(hash, user_hash)
    user_hash.each do |i|
      hash['items'] << i
    end

    hash
  end

  def self.action(id, user, action_id)
    Level.find(user.location).chests.find(id).action(user, action_id)
  end

  def self.prepare_user(user)
    if !user.is_a? User
      user = User.find(user)
    end

    u_items = user.inventory.items
    w = 6
    h = 40 / w

    r = []

    (0..(u_items.count - 1)).each do |i|
      r << { x: i % w, y: i / w + 1, name: u_items[i].name, id: u_items[i].id.to_s }
    end

    r
  end

  def action(user, action_id)
    if action_id == 'back'
      State.clear(user)
      return
    end

    c_items = inventory.items
    u_items = user.inventory.items

    if c_items.any? { |i| i.id.to_s == action_id }
      item = c_items.find(action_id)
      u_items << item.clone
      c_items.delete(item)
      save
    elsif u_items.any? { |i| i.id.to_s == action_id }
      item = u_items.find(action_id)
      c_items << item.clone
      u_items.delete(item)
      save
    end

    State.change(user, Chest, id.to_s)
    State.update(id.to_s, abstract_show)
  end

  def self.random_generate(x, y)
    c = new(x: x, y: y, inventory: Inventory.new(items: []))
    (0..rand(20)).each do |_|
      c.inventory.items << Item.random_generate
    end
    c
  end
end
