
class Snake
  def initialize
    @direction = 'right'
    @snake = [{x: 1, y: 1}]
    @ruby = {x: 10, y: 5}
    @time = Time.now.to_i
  end

  def show(user_hash)
    current_time = Time.now.to_i
    w = 20
    h = 10
    r = user_hash['r']

    if current_time >= @time + 1
      @time = @time + 1
      head = @snake.last.clone
      case @direction
      when 'right'
        head['x'] += 1
      when 'left'
        head['x'] -= 1
      when 'up'
        head['y'] -= 1
      when 'down'
        head['y'] += 1
      end
      
      if head['x'] < 1 || head['x'] >= w || 
        head['y'] < 1 || head['y'] >= h ||
        @snake.any?{|s| s == head} 
        @snake = JSON.load([{'x': 1, 'y': 1}].to_json)
        @direction = 'right'
      else
        if head == @ruby
          @ruby = JSON.load({ x: rand(w - 1) + 1, y: rand(h - 1) + 1 }.to_json)
        else
          @snake.delete_at(0)
        end
        @snake << head
      end

      State.change_id(user_hash['id'], Snake, self)
    end
    
    r << {x: @ruby['x'], y: @ruby['y'], name: 'ruby'}
    
    @snake.each do |s|
      r << {x: s['x'], y: s['y'], name: 'ghost'}
    end

    { width: w, height: h + 2, floor: :chest_bottom, wall: :chest_wall, items: r }
  end

  def self.prepare_user(user)
    prepare_user_id(user.id.to_s)
  end

  def self.prepare_user_id(user_id)
    w = 20
    h = 10
    r = [{ x: 0, y: 0, name: :back, id: 'back' }]

    (1..h-1).each do |i|
      r << { x: 0, y: i, name: 'chest_wall' }
    end

    (1..w-1).each do |i|
      r << { x: i, y: 0, name: 'chest_wall' }
    end

    (h..h+1).each do |j|
      (0..w-1).each do |i|
        if i == w / 2
          if j == h 
            r << { x: i, y: j, name: :up_arrow, id: 'up' }
          else
            r << { x: i, y: j, name: :down_arrow, id: 'down' }
          end
        elsif i == w / 2 - 1 && j == h + 1
          r << { x: i, y: j, name: :left_arrow, id: 'left' }
        elsif i == w / 2 + 1 && j == h + 1
          r << { x: i, y: j, name: :right_arrow, id: 'right' }
        else
          r << { x: i, y: j, name: 'chest_wall' }
        end
      end
    end
    {r: r, id: user_id}
  end

  def action(user, action_id)
    if action_id == 'back'
      State.clear(user)
    else
      @direction = action_id
      State.change(user, Snake, self)
    end
  end

  def self.from_hash hash
    f = Snake.new
    hash.each do |var, val|
      f.instance_variable_set ('@' + var), val
    end
    f
  end
end
