
class Fight
  def initialize(user)
    return unless user

    @time = Time.now.to_i
    @assaulter = 'user'
    unless user.bond
      user.bond = 0
    end
    @user_hp = user.bond
    @monster_hp = 2
  end
 
  def hp(number)
    'hp_' + number.to_s
  end

  def self.show(hash, user_id, user_hash)
    from_hash(hash).show(user_hash)
  end

  def show(user_hash)
    dt = 3 +  @time - Time.now.to_i
    if dt < 0
      dt = 3
      @time = Time.now.to_i
      if @assaulter == 'user'
        @assaulter = 'monster'
      else
        @assaulter = 'user'
      end
      State.change(user_hash['id'], Fight, self)
    end
    time_anim = 'time_' + dt.to_s

    r = []
    r << { x: (@assaulter == 'user') ? 5 : 1, y: 4, name: time_anim }
    r << { x: (@assaulter == 'monster') ? 5 : 1, y: 4, name: :time_0 }
    r << { x: 1, y: 2, name: :monster }
    r << { x: 5, y: 2, name: :ghost }
    r << { x: 0, y: 0, name: :back, id: :back }
    
    r << { x: 1, y: 1, name: hp(@monster_hp) }
    r << { x: 5, y: 1, name: hp(@user_hp > 2 ? 2 : @user_hp) }
    r << { x: 6, y: 1, name: hp(@user_hp < 2 ? 0 : @user_hp - 2) }
    if @assaulter == 'user' && user_hash['item']
      r << user_hash['item']
    end

    { width: 7, height: 5, floor: :chest_bottom, wall: :chest_wall, items: r }
  end

  def self.prepare_user(user)
    if !user.is_a? User
      user = User.find(user)
    end
    if user.item
      {id: user.id.to_s, item: { x: 4, y: 3, name: user.item.name, id: :impact}}
    else
      {id: user.id.to_s, item: nil}
    end
  end

  def self.action(hash, user, action_id)
    Fight.from_hash(hash).action(user, action_id)
  end

  def action(user, action_id)
    if action_id == 'back'
      State.clear(user)
    elsif action_id == 'impact'
      if @assaulter == 'user'
        if user.item 
          @monster_hp -= user.item.damage
          if @monster_hp < 0
            State.clear(user)
          else
            State.change(user, Fight, self)
          end
        end
      end
    end
  end

  def self.from_hash hash
    f = Fight.new(nil)
    hash.each do |var, val|
        f.instance_variable_set ('@' + var), val
    end
    f
  end
end