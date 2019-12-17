

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
    cls.show(@value, user_id, @meta)
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
    user_id = user
    if user_id.is_a? User
      user_id = user.id.to_s
    end
    update(user_id, State.new(cls, value, cls.prepare_user(user)))
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
    cls.action(@value, user, action_id)
  end

  def self.load(key)
    $redis_action.get(key)
  end
end
