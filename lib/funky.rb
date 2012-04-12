require 'asm'

Assembler.new.code do
  class << self
      include R16::Memory   # include modules with functions
      include R16::StdString # include modules with functions
  end
  set :pc, :main

  declare_function :memcpy, :mapping=>3
  declare_function :strncpy, :inline=>true
  declare_function :println, :mapping=>3

  define_functions

  set_label :main

  call :println, 17, 15, :copyright

  set :x, 0
  set :y, 15

  set_label :loop
  coord_to_addr :z, :x, :y
  add :z, 1
  call :memcpy, :z, :remove, 4

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
  colored_text 0x0000, "FUNKY"

  set_label :remove
  fill 0x0000, 5

  set_label :sin_table
  data = 32.times.collect do |i|
    e = Math.sin(i/32.0*360.0*Math::PI/180.0)*7 + 8
    e.floor
  end
  dat *data

  set_label :copyright
  colored_text 0x0000, "powered by r16"

end

