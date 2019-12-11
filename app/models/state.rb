

class State
  def initialize(name, value)
    @name = name
    @value = value
  end

  def self.show(user_id)

    state = $redis_action.get(user_id)
    if state
      state = State.from_json(state)
    else
      state = State.new('level', User.all.find(user_id).location)
      $redis_action.set(user_id, state.to_json, ex: 600)
    end
    state.show(user_id)
  end

  def self.action(user, action_id)

    state = $redis_action.get(user.id)
    if state
      state = State.from_json(state)
    else
      state = State.new('level', user.location)
      $redis_action.set(u.id, state.to_json, ex: 600)
    end
    state.action(user, action_id)
  end
  
  def self.change(user_id, name, value)
    $redis_action.set(user_id, State.new(name, value).to_json, ex: 600)
  end

  def self.from_json string
    s = State.new(nil, nil)
    JSON.load(string).each do |var, val|
        s.instance_variable_set ('@' + var), val
    end
    s
  end

  def self.clear(user)
    change(user.id, 'level', user.location)
  end

  def action(user, action_id)
    if @name == 'level'
      Level.find(@value).action(user, action_id)
    elsif @name == 'chest'
      Level.find(user.location).chests.find(@value).action(user, action_id)
    elsif @name == 'fight'
      Fight.from_hash(@value).action(user, action_id)
    end
  end
  
  def self.update_chest(chest_id, hash)
    $redis_action.set(chest_id, hash.to_json, ex: 600)
  end

  def show_level(level_id, user_id)
    level = $redis_action.get(level_id)
    if !level
      level = Level.find(level_id).abstract_show.to_json
      $redis_action.set(level_id, level, ex: 600)
    end
    Level.add_user(JSON.load(level), user_id)
  end

  def show_chest(chest_id, user_id)
    chest = $redis_action.get(chest_id)
    if !chest
      chest = Level.find(User.find(user_id).location).chests.find(chest_id).abstract_show.to_json
      $redis_action.set(chest_id, chest, ex: 600)
    end
    Chest.add_user(JSON.load(chest), user_id)
  end

  def show(user_id)
    if @name == 'level'
      show_level(@value, user_id)
    elsif @name == 'chest'
      show_chest(@value, user_id)
    elsif @name == 'fight'
      Fight.from_hash(@value).show(User.find(user_id))
    end
  end
end
