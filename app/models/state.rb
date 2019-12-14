

class State
  def initialize(cls, value, meta)
    @name = cls.name
    @value = value
    @meta = meta
  end

  def self.show(user_id)
    state = $redis_action.get(user_id)
    if state
      state = State.from_json(state)
    else
      user = User.all.find(user_id)
      state = State.new(Level, user.location, Level.prepare_user(user))
      $redis_action.set(user_id, state.to_json, ex: 600)
    end
    state.show(user_id)
  end

  def show(user_id)
    cls = Object.const_get(@name)
    hash = nil
    if cls == Chest
      hash = load_chest(@value, user_id)
    elsif cls == Level
      hash = load_level(@value, user_id)
    elsif cls == Fight
      return Fight.from_hash(@value).show(@meta)
    elsif cls == Menu
      return Menu.from_hash(@value).show(@meta)
    else
      raise TypeError, "unknown type " + @name
    end
  
    cls.add_user(hash, @meta)
  end

  def self.action(user, action_id)

    state = $redis_action.get(user.id)
    if state
      state = State.from_json(state)
    else
      state = State.new(Level, user.location, Level.prepare_user(user))
      $redis_action.set(user.id, state.to_json, ex: 600)
    end
    state.action(user, action_id)
  end

  def self.change(user, cls, value)
    update(user.id, State.new(cls, value, cls.prepare_user(user)))
  end

  def self.change_id(user_id, cls, value)
    update(user_id, State.new(cls, value, cls.prepare_user_id(user_id)))
  end

  def self.update(item_id, value)
    $redis_action.set(item_id.to_s, value.to_json, ex: 600)
  end

  def self.from_json string
    s = State.new(Object, nil, nil)
    JSON.load(string).each do |var, val|
        s.instance_variable_set ('@' + var), val
    end
    s
  end

  def self.clear(user)
    change(user, Level, user.location)
  end

  def action(user, action_id)
    cls = Object.const_get(@name)

    if cls == Chest
      Level.find(user.location).chests.find(@value).action(user, action_id)
    elsif cls == Level
      Level.find(@value).action(user, action_id)
    elsif cls == Fight
      Fight.from_hash(@value).action(user, action_id)
    elsif cls == Menu
      Menu.from_hash(@value).action(user, action_id)
    else
      raise TypeError, "unknown type " + @name
    end
  end

private
  def load_level(level_id, user_id)
    level = $redis_action.get(level_id)
    if !level
      level = Level.find(level_id).abstract_show
      State.update(level_id, level)
      level = level.to_json
    end
    JSON.load(level)
  end

  def load_chest(chest_id, user_id)
    chest = $redis_action.get(chest_id)
    if !chest
      chest = Level.find(User.find(user_id).location).chests.find(chest_id).abstract_show
      State.update(chest_id, chest)
      chest = chest.to_json
    end
    JSON.load(chest)
  end
end
