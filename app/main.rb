class Sphere
  def initialize x1, x2, y1, y2, vy, sprite
    @x1 ||= x1
    @x2 ||= x2
    @y1 ||= y1
    @y2 ||= y2
    @x ||= x1
    @y ||= y1
    @vy ||= vy
    @sprite ||= sprite
    @slope ||= (@y2 - @y1) / (@x2 - @x1)
    @size ||= 64
  end

  def x
    @x
  end

  def y
    @y
  end

  def vy
    @vy
  end

  def sprite
    @sprite
  end

  def size
    @size
  end

  def tick
    if @vy > 0
      if @y + @vy > @y2 then
        @vy = -@vy
      end
    else
      if @y + @vy < (@y1 - @size / 2) then
        @vy = -@vy
      end
    end
    @size = 64 - (64 * (@y/@y2))
    @y += @vy
    @x = @y/@slope + @x1 - (@size / 2) + (((640 - @x1)/640) * @size)
  end
end

class Dragon
  def initialize x, y, vx, vy, sprites
    @x ||= x
    @y ||= y
    @vy ||= vy
    @vx ||= vx
    @flip_horizontally ||= false
    @sprites ||= sprites
    @current ||= 0
    @anim_delay ||= 10
    @max_delay ||= 10
    @size ||= 64
  end

  def x
    @x
  end

  def y
    @y
  end

  def sprite
    @sprites[@current]
  end

  def flip_horizontally
    @flip_horizontally
  end

  def size
    @size
  end

  def tick
    @x += @vx
    @y += @vy
    if @x > 1280
      @vx = -@vx
      @flip_horizontally = true
    elsif @x < (0 - @size)
      @vx = -@vx
      @flip_horizontally = false
    end
    if @y > (720 - @size)
      @vy = -@vy
    elsif @y < 360
      @vy = -@vy
    end

    @anim_delay -= 1
    if @anim_delay == 0
      @anim_delay = @max_delay
      @current += 1
      if @current == @sprites.length
        @current = 0
      end
    end
  end
end

class HelloGame
  def initialize args
    @args = args
    @center_x = 1280/2
    @center_y = 720/2
    @rotation ||= 0
    @icon_x ||= @center_x - 64
    @icon_y ||= 280
    @merge_x ||= @center_x
    @merge_y ||= @center_y
    @spheres ||= []

    sprites = ['sprites/misc/dragon-1.png', 'sprites/misc/dragon-2.png', 'sprites/misc/dragon-3.png',
               'sprites/misc/dragon-4.png', 'sprites/misc/dragon-3.png','sprites/misc/dragon-2.png']
    @dragon = Dragon.new(@center_x, @center_y, 1, 1, sprites)

    if @spheres.length == 0
      sprites = ['sprites/misc/star.png']
      0.step(1280, 128) do |x|
        @spheres.append(Sphere.new(x, @merge_x, 0, @merge_y, 1 + Math.sin(x).abs(), sprites.sample()))
      end
    end

  end

  def render_background
    @args.outputs.solids << [0, 0, 1280, 720, 64, 64, 64]
    line_color = [64,128,255]
    x = 0
    while x <= 1280
      @args.outputs.primitives << [@merge_x, @merge_y, x, 0, *line_color].lines
      x += 128
    end

    y = 0
    while y < @merge_y
      @args.outputs.primitives << [0, y, 1280, y, *line_color].lines
      y += (@merge_y - y)/10 + 10
    end
    for s in @spheres
      @args.outputs.primitives << [s.x, s.y, s.size, s.size, s.sprite, (s.y * s.vy)].sprites
    end

    @args.outputs.primitives << {x: @dragon.x, y: @dragon.y, w: 64, h: 64, path: @dragon.sprite,
                                 flip_horizontally: @dragon.flip_horizontally}.sprite!
  end

  def render_text
    @args.outputs.primitives  << [@center_x, 500, 'Hello Classy DragonRuby World!', 5, 1, 127, 127, 127].labels
  end

  def render_icon
    # @args.outputs.primitives << [@icon_x, @icon_y, 128, 101, 'dragonruby.png', 0, 128].sprites
  end

  def render
    render_background
    render_text
    render_icon
  end

  def game_tick
    if @args.inputs.mouse.click
      @icon_x = @args.inputs.mouse.click.point.x - 64
      @icon_y = @args.inputs.mouse.click.point.y - 50
    end
    @rotation -= 1
    render
    @dragon.tick()
    for s in @spheres
      s.tick()
    end
  end
end

class Stars
  def initialize cx, cy, ir, vr, sprite, args
    @cx ||= cx
    @cy ||= cy
    @r ||= ir
    @vr ||= vr
    @sprite ||= sprite
    @args ||= args
  end

  def render
    size = (@r/360)*16
    0.step(360, 12).each do |t|
      x = @cx + @r * Math.cos((t - (@r)) * Math::PI/180)
      y = @cy + @r * Math.sin((t - (@r)) * Math::PI/180)
      @args.outputs.primitives << [x, y, 16, 16, @sprite].sprites
    end
  end

  def tick
    @r += 1
    if @r > 360
      @r = 1
    end
    render
  end
end


def tick args
  args.state.game ||= HelloGame.new args
  args.state.game.game_tick
  cx = 1280/2
  cy = 729/2
  args.state.s1 ||= Stars.new(cx, cy, 1, 1, 'sprites/misc/tiny-star.png', args)
  args.state.s2 ||= Stars.new(cx, cy, 120, 1, 'sprites/misc/tiny-star.png', args)
  args.state.s3 ||= Stars.new(cx, cy, 240, 1, 'sprites/misc/tiny-star.png', args)

  args.state.s1.tick
  args.state.s2.tick
  args.state.s3.tick
end
