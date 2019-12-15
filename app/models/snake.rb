
class Snake
  W = 17
  H = 7

  def initialize
    @direction = 'right'
    @snake = [{x: 1, y: 1}]
    @ruby = {x: W / 2, y: H / 2}
    @time = Time.now.to_i
  end

  def show(user_hash)
    current_time = Time.now.to_i
    r = user_hash['r']

    if current_time >= @time + 1
      @time = current_time
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
      
      if head['x'] < 1 || head['x'] >= W || 
        head['y'] < 1 || head['y'] >= H ||
        @snake.any?{|s| s == head} 
        @snake = JSON.load([{'x': 1, 'y': 1}].to_json)
        @direction = 'right'
      else
        @snake << head
        if head == @ruby
          if @snake.size == (W - 1) * (H - 1)
            @snake.each do |s|
              r << {x: s['x'], y: s['y'], name: 'ruby'}
            end

            return { width: W, height: H + 2, floor: :chest_bottom, wall: :chest_wall, items: r }
          end
          begin
            @ruby = JSON.load({ x: rand(W - 1) + 1, y: rand(H - 1) + 1 }.to_json)
          end while @snake.any?{|s| s == @ruby}
        else
          @snake.delete_at(0)
        end
      end

      State.change_id(user_hash['id'], Snake, self)
    end
    
    r << {x: @ruby['x'], y: @ruby['y'], name: 'ruby'}
    
    @snake.each do |s|
      r << {x: s['x'], y: s['y'], name: 'ghost'}
    end

    { width: W, height: H + 2, floor: :chest_bottom, wall: :chest_wall, items: r }
  end

  def self.prepare_user(user)
    prepare_user_id(user.id.to_s)
  end

  def self.prepare_user_id(user_id)
    r = [{ x: 0, y: 0, name: :back, id: 'back' }]

    (1..H-1).each do |i|
      r << { x: 0, y: i, name: 'chest_wall' }
    end

    (1..W-1).each do |i|
      r << { x: i, y: 0, name: 'chest_wall' }
    end

    (H..H+1).each do |j|
      (0..W-1).each do |i|
        if i == W / 2
          if j == H
            r << { x: i, y: j, name: :up_arrow, id: 'up' }
          else
            r << { x: i, y: j, name: :down_arrow, id: 'down' }
          end
        elsif i == W / 2 - 1 && j == H + 1
          r << { x: i, y: j, name: :left_arrow, id: 'left' }
        elsif i == W / 2 + 1 && j == H + 1
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
