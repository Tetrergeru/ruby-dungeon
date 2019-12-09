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

  def show(user)
    redis_data = $redis_action.get(user.id)
    
    if redis_data
      condition = JSON.load(redis_data)

      if condition['action'] == 'chest'
        return chests.find(condition['chest_id']).show(user)
      elsif condition['action'] == 'fight'
        Fight.from_json(condition['fight'].to_json).show(user)
      end
    else
      to_json
    end
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

  def action(user, action_id)
    redis_data = $redis_action.get(user.id)
    if redis_data
      condition = JSON.load(redis_data)
      if condition['action'] == 'chest'
        chests.find(condition['chest_id']).action(user, action_id)
      end
      if condition['action'] == 'fight'
        Fight.from_json(condition['fight'].to_json).action(user, action_id)
      end

    elsif chests.any? { |i| i.id.to_s == action_id }
      $redis_action.set(user.id, {action: :chest, chest_id: action_id}.to_json, ex: 600)
    elsif monsters.any? { |i| i.id.to_s == action_id }
      $redis_action.set(user.id, {action: :fight, fight: Fight.new}.to_json, ex: 600)
    elsif doors.any? { |i| i.id.to_s == action_id }
      doors.find(action_id).action(user, action_id)
    end
    save
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

  private

  def to_json(*_args)
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

    { width: width, height: height, floor: :floor, wall: :wall, items: r }
  end
end
