
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
        if !(i == w / 2 + w && j == h / 2 - 1)
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
    u_items = user.inventory.items
    w = 6
    h = 40 / w

    r = []

    (0..(u_items.count - 1)).each do |i|
      r << { x: i % w, y: i / w + 1, name: u_items[i].name, id: u_items[i].id.to_s }
    end
    if user.item
      r << { x: w / 2 + w, y: h / 2 - 1, name: user.item.name, id: user.item.id.to_s}
    end
    { items: r}
  end

  def self.prepare_user_id(user_id)
    prepare_user(User.find(user_id))
  end

  def self.action(hash, user, action_id)
    Menu.from_hash(hash).action(user, action_id)
  end

  def action(user, action_id)
    items = user.inventory.items

    if action_id == 'back'
      State.clear(user)
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