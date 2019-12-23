# frozen_string_literal: true

require 'mongoid'

# Level
class Level
  include Mongoid::Document
  field :width, type: Integer
  field :height, type: Integer

  embeds_many :chests
  embeds_many :monsters
  embeds_many :walls
  embeds_many :doors

  def self.show(id, user_id, user_hash)
    level = State.load(id)
    if !level
      level = Level.find(id).abstract_show
      State.update(id, level)
      level = level.to_json
    end
    Level.add_user(JSON.load(level), user_hash)
  end

  def abstract_show
    r = []

    chests.all.each do |c|
      r << { id: c.id.to_s, x: c.x, y: c.y, name: :chest }
    end

    monsters.all.each do |c|
      r << { id: c.id.to_s, x: c.x, y: c.y, name: :monster }
    end

    walls.all.each do |c|
      r << { x: c.x, y: c.y, name: :wall }
    end

    doors.all.each do |c|
      r << { id: c.id.to_s, x: c.x, y: c.y, name: :door }
    end

    width.times do |i|
      r << { x: i, y: height, name: :wall }
    end

    height.times do |i|
      r << { x: width, y: i, name: :wall }
    end

    { width: width + 1, height: height + 1, floor: :floor, wall: :wall, items: r }
  end

  def self.add_user(hash, meta)
    meta['x'] = hash['width'] - 1
    meta['y'] = hash['height'] - 1
    hash['items'] << meta
    hash
  end

  def self.prepare_user(user)
    { id: :menu, x: nil, y: nil, name: :ghost }
  end

  def self.action(id, user, action_id)
    Level.find(id).action(user, action_id)
  end

  def action(user, action_id)
    if action_id == 'menu'
      State.change(user, Menu, Menu.new)
    elsif action_id == 'snake'
      State.change(user, Snake, Snake.new)
    elsif chests.any? { |i| i.id.to_s == action_id }
      State.change(user, Chest, action_id)
    elsif monsters.any? { |i| i.id.to_s == action_id }
      State.change(user, Fight, Fight.new(user))
    elsif doors.any? { |i| i.id.to_s == action_id }
      doors.find(action_id).action(user, action_id)
    end
    save
  end

  def self.random_generate(owner = nil)
    l = Level.create(width: rand(5..14), height: rand(5..14))

    (0..(l.width - 1)).each do |i|
      (0..(l.height - 1)).each do |j|
        l.generate_random_item(i, j)
      end
    end

    if l.doors.count < 2
      l.delete
      return random_generate(owner)
    end

    if owner
      d = l.doors[rand(l.doors.count)]
      d.target_level = owner.id
      d.save
    end
    l
  end

  def show_item(item_id)
    i = chests.select { |c| c.id.to_s == item_id }
    return 'not correct id' if i.empty?

    i[0].show
  end

  def generate_random_item(x, y)
    case rand(10)
    when 0
      chests << Chest.random_generate(x, y)
    when 1
      monsters << Monster.new(x: x, y: y)
    when 2
      walls << Wall.new(x: x, y: y)
    when 3
      doors << Door.new(x: x, y: y)
    end
  end
end
