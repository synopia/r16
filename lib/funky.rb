require 'r16/assembler'


module R16::Memory
  def memcpy target, source, n
    # target->:a, source->:b, n->:c
    do_while proc{ifn :c, 0} do
      set [:a], [:b]
      add :a, 1
      add :b, 1
      sub :c, 1
    end
  end
end

module R16::StdString
  def strncpy target, source, n
    do_while proc{ifn n, 0} do
      set [target], [source]
      add target, 1
      add source, 1
      sub n, 1
      ife [source], 0
      set n, 0
    end
  end

  def print x, y, str
    coord_to_addr y, x, y
    call :strncpy, y, str, 0x100
  end

  def coord_to_addr target, x, y
    set target, y
    shl target, 5
    add target, x
    add target, 0x8000
  end
end

include R16
include R16::Operands
include R16::Memory
include R16::StdString

R16::Assembler.code do
  set :pc, :main

  def_function :memcpy, :params=>3
  def_function :strncpy, :params=>3
  def_function :print, :params=>3

  set_label :main

  call :print, 17, 15, :copyright

  set :x, 0
  set :y, 15

  set_label :loop
  coord_to_addr :z, :x, :y

  call :memcpy, :z, :remove, 5

  add :x, 1
  mod :x, 32
  set :a, :sin_table
  add :a, :x
  set :y, [:a]
  coord_to_addr :z, :x, :y
  call :memcpy, :z, :funky, 5

  set :a, 1000
  wait :a

  set :pc, :loop


  set_label :end
  set :pc, :main

  set_label :funky
  colored_text 0x4000, "FUNKY"

  set_label :remove
  fill 0x0000, 5

  set_label :sin_table
  data = 32.times.collect do |i|
    e = Math.sin(i/32.0*360.0*Math::PI/180.0)*7 + 8
    e.floor
  end
  dat *data

  set_label :copyright
  colored_text 0x0000, "(c)funky-clan"

end

