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
      if @y + @vy < @y1 then
        @vy = -@vy
      end
    end
    @size = 64 - 64 * (@y/360)
    @y += @vy
    @x = @y/@slope + @x1 - (size/2)
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

    if @spheres.length == 0
      sprites = ['sprites/circle/black.png', 'sprites/circle/blue.png', 'sprites/circle/gray.png',
                 'sprites/circle/green.png', 'sprites/circle/indigo.png', 'sprites/circle/orange.png',
                 'sprites/circle/red.png', 'sprites/circle/violet.png', 'sprites/circle/white.png',
                 'sprites/circle/yellow.png']
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
    for s in @spheres
      s.tick()
    end
  end
end



def tick args
  args.state.game ||= HelloGame.new args
  args.state.game.game_tick
end
