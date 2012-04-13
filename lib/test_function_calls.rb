require 'asm'

Assembler.new.code do
  set :pc, :main
  declare_function :foo,   :params=>4, :locals=>1
  declare_function :bar,   :params=>4
  declare_function :coord_to_addr,   :params=>2
  declare_function :main,  :params=>0

  def foo(a, b, c, d)
    e = locals
    op( a.set! e )
    op( op(d).set! a )
    call :bar, a, b, c, d
  end
  def bar(a, b, c, d)
    set [a], [b]
    set [c], d
  end
  def coord_to_addr x, y
    op( op(:a).set! (y<<5)+x+0x8000)

  end

  def main
   call :coord_to_addr, 0,0
   call :coord_to_addr, 31,0
   call :coord_to_addr, 31,15
   call :coord_to_addr, 0,15
   call :coord_to_addr, op(:x),15
  end

  define_functions

end