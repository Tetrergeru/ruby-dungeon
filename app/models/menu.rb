
class Menu

  def self.show(hash, user_id, user_hash)
    from_hash(hash).show(user_hash)
  end

  def show(user_hash)
    w = 6
    h = 40 / w
    r = [{ x: 0, y: 0, name: :back, id: 'back' }]


    h.times do |j|
      (w..(2 * w)).each do |i|
        unless (i == w + 1 && j == 1) || ((i == w + 3 || i == w + 4) && (j == 1 || j == 2 || j == 3))
          r << { x: i, y: j, name: 'chest_wall' }
        end
      end
    end

    user_hash['items'].each do |i|
      r << i
    end

    { width: w * 2 + 1, height: h, floor: :chest_bottom, wall: :chest_wall, items: r }
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
    if user.item
      r << { x: w + 1, y: 1, name: user.item.name, id: user.item.id.to_s}
    end

    unless user.poltergeisting
      user.poltergeisting = 0
    end
    r << { x: w + 4, y: 1, name: 'points_' + user.poltergeisting.to_s}
    r << { x: w + 3, y: 1, name: 'poltergeist_0', id: 'poltergeisting'}

    unless user.transparency
      user.transparency = 0
    end
    r << { x: w + 4, y: 2, name: 'points_' + user.transparency.to_s}
    r << { x: w + 3, y: 2, name: 'transparency_0', id: 'transparency'}

    unless user.bond
      user.bond = 0
    end
    r << { x: w + 4, y: 3, name: 'points_' + user.bond.to_s}
    r << { x: w + 3, y: 3, name: 'bond_0', id: 'bond'}


    { items: r}
  end

  def self.action(hash, user, action_id)
    Menu.from_hash(hash).action(user, action_id)
  end

  def action(user, action_id)
    items = user.inventory.items

    if action_id == 'back'
      State.clear(user)
    elsif action_id == 'poltergeisting'
      user.poltergeisting = (user.poltergeisting + 1) % 5
      State.change(user, Menu, self)
    elsif action_id == 'transparency'
      user.transparency = (user.transparency + 1) % 5
      State.change(user, Menu, self)
    elsif action_id == 'bond'
      user.bond = (user.bond + 1) % 5
      State.change(user, Menu, self)
    elsif user.item && user.item.id.to_s == action_id
      items << user.item.clone
      user.item = nil
      State.change(user, Menu, self)
    elsif items.any? { |i| i.id.to_s == action_id }
      item = items.find(action_id)
      if user.item
        items << user.item.clone
      end
      user.item = item.clone
      items.delete(item)
      State.change(user, Menu, self)
    end
  end

  def self.from_hash hash
    f = Menu.new
    hash.each do |var, val|
      f.instance_variable_set ('@' + var), val
    end
    f
  end
end