require 'r16/assembler'



include R16
include R16::Operands
include R16::Memory
include R16::StdString

R16::Assembler.code do
  set :pc, :main

  dat :ball_x,       15<<8
  dat :ball_y,        7<<8
  dat :ball_dir_x,    1<<8
  dat :ball_dir_y,    1<<8+1
  dat :left_paddle,   0
  dat :right_paddle,  0

  colored_text :funky,     "FUNKY"
  colored_text :copyright, "powered by r16"

  fill :remove, 0x0000, 5

  data = 64.times.collect do |i|
    e = Math.sin(i/64.0*360.0*Math::PI/180.0)*7 + 8
    e.floor
  end
  dat :sin_table, *data

  def_function :memcpy, :params=>3
  def_function :strncpy, :params=>3
  def_function :print, :params=>3

  def draw_paddle pos, n, dx
    sub pos, dx
    set [pos], 0x00
    add pos, dx
    while_do proc{ ife n, 0} do
      set [pos], 0x30
      sub n, 1
      add pos, dx
    end
    set [pos], 0x00
  end

  def draw_ball x, y, char
    set :a, [x]
    shr :a, 8
    set :b, [y]
    shr :b, 8
    coord_to_addr :x, :a, :b
    set [:x], char
  end

  def move_ball ball, ball_dir, step_offset, max
    set :x, [ball]
    add :x, [ball_dir]
    sub :x, step_offset
    if_then proc{ifb :o, 1} do
      set :x, (max>>1)
    end
    if_then proc{ifg :x, max} do
      set :x, (max>>1)
    end
    set [ball], :x
  end

  def_function :draw_paddle, :params=>3
  #def_function :move_ball,   :params=>2
  def_function :draw_ball,   :params=>3

  set_label :main

  #call :print, 17, 15, :copyright

  set :x, 1
  set :y, 1
  set :b, 0

  set_label :loop

  call :draw_ball, :ball_x, :ball_y, 0x00
  move_ball :ball_x, :ball_dir_x, 1<<8, 31<<8
  move_ball :ball_y, :ball_dir_y, 1<<8, 15<<8
  call :draw_ball, :ball_x, :ball_y, 0x30

=begin
  set :y, [:sin_table, :b]
  coord_to_addr :z, 0, :y
  set [:left_paddle], :z

  set :y, :sin_table
  add :y, :b
  add :y, 16
  coord_to_addr :z, 31, [:y]
  set [:right_paddle], :z


  call :draw_paddle, [:left_paddle], 4, 32
  call :draw_paddle, [:right_paddle], 4, 32
=end


  set :a, 1000
  #wait :a

  add :b, 1
  mod :b, 64
  set :pc, :loop

  set_label :end
  set :pc, :main

end

