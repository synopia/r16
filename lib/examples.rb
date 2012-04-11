require 'r16/assembler'


include R16

R16::Assembler.data do

end


R16::Assembler.code do
  set :pc, :main
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

  def_function :print, :params=>3

  set_label :main

  call :print, 2, 3, :hello
  call :print, 3, 4, :world

  set_label :end
  set :pc, :main

  set_label :hello
  colored_text 0xf000, "Hello"

  set_label :world
  colored_text 0xf200, "World"




=begin
  def foo a, b, c, d
    call :foo, 1,2,3,4
  end

  foo( 1, 2, 3, 4)

  def_function :foo, :params=>4, :locals=>0
=end



=begin
  def a_to_i n, p
    i = get_local 0
    j = get_local 1
    z = get_local 2
    a = get_local 3
    set j, 0
    loop_while proc{ife n, 0} do
      mod2 i, n, 10
      div n, 10
      set push, i
      add j, 1
    end
    set z, 0
    loop_while proc{ife j, 0} do
      set i, pop
      add2 a, (0xf000 | 0x30), i
      add2 R[:Y], p, z
      set [R[:Y]], a
      sub j, 1
      add z, 1
    end
  end


  call :a_to_i, 0xfefe, 0x8000

  set_label :crash
  set R[:PC], :crash

  def_function :a_to_i, :params=>2, :locals=>4
=end
end

