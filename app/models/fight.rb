
class Fight
  def initialize 
    @time = Time.now.to_i
    @assaulter = 'user'
    @user_hp = 2
    @monster_hp = 2
  end
 
  def hp(number)
    'hp_' + number.to_s
  end

  def show(user_id)
    dt = 3 +  @time - Time.now.to_i
    if dt < 0
      dt = 3
      @time = Time.now.to_i
      if @assaulter == 'user'
        @assaulter = 'monster'
      else
        @assaulter = 'user'
      end
      State.change(user_id, 'fight', self)
    end
    time_anim = 'time_' + dt.to_s

    r = []
    r << { x: (@assaulter == 'user') ? 5 : 1, y: 4, name: time_anim }
    r << { x: (@assaulter == 'monster') ? 5 : 1, y: 4, name: :time_0 }
    r << { x: 1, y: 2, name: :monster }
    r << { x: 5, y: 2, name: :ghost }
    r << { x: 0, y: 0, name: :back, id: :back }
    
    r << { x: 1, y: 1, name: hp(@monster_hp) }
    r << { x: 5, y: 1, name: hp(@user_hp) }
    if @assaulter == 'user'
      r << { x: 4, y: 3, name: :aim, id: :impact}
    end

    { width: 7, height: 5, floor: :chest_bottom, wall: :chest_wall, items: r }
  end

  def action(user, action_id)
    if action_id == 'back'
      State.clear(user)
    elsif action_id == 'impact'
      if @assaulter == 'user'
        @monster_hp -= 1
        if @monster_hp < 0
          State.clear(user)
        else
          State.change(user.id, 'fight', self)
        end
      end
    end
  end

  def self.from_hash hash
    f = Fight.new
    hash.each do |var, val|
        f.instance_variable_set ('@' + var), val
    end
    f
  end
end