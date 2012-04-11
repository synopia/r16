require 'r16/assembler'



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
  colored_text 0x0000, "powered by r16"

end

