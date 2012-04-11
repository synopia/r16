require 'r16/assembler'

include R16
include R16::Operands

lR16::Assembler.code do
  set :pc, :main

  def memcpy target, source, n
    # target->:a, source->:b, n->:c
    do_while proc{ifn :c, 0} do
      set [:a], [:b]
      add :a, 1
      add :b, 1
      sub :c, 1
    end
  end
  def_function :memcpy, :params=>3
  def print x, y, str
    set :x, 0
    set :y, x
    shl :y, 5
    add :y, x
    do_while proc{ifn :a, 0} do
      set :a, :x
      add :a, str
      set :a, [:a]
      set [0x8000,:y], :a
      add :x, 1
      add :y, 1
    end
  end

  def coord_to_addr target, x, y
    set target, :y
    shl target, 5
    add target, :x
    add target, 0x8000
  end

  def_function :print, :params=>3

  set_label :main
  set :x, 0
  set :y, 16

  set_label :loop
  coord_to_addr :a, :x, :y

  call :memcpy, :a, :remove, 5

  add :x, 1
  mod :x, 16
  sub :y, 1
  mod :y, 16

  coord_to_addr :a, :x, :y
  call :memcpy, :a, :funky, 5

  set :pc, :loop


  set_label :end
  set :pc, :main

  set_label :funky
  colored_text 0xf000, "FUNKY"

  set_label :remove
  colored_text 0xf200, "     "

end

