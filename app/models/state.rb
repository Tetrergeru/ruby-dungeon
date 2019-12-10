

class State
  def initialize(name, value)
    @name = name
    @value = value
  end

  def self.show(user)

    state = $redis_action.get(user.id)
    if state
      state = State.from_json(state)
    else
      state = State.new('level', user.location)
      $redis_action.set(user.id, state.to_json, ex: 600)
    end
    state.show(user)
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
  
  def show(user)
    if @name == 'level'
      Level.find(@value).show(user)
    elsif @name == 'chest'
      Level.find(user.location).chests.find(@value).show(user)
    elsif @name == 'fight'
      Fight.from_hash(@value).show(user)
    end
  end
end
