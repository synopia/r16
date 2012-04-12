require 'asm'

Assembler.new.code do
  set :pc, :main
  declare_function :foo,   :mapping=>4
  declare_function :bar,   :mapping=>4

  def foo(a, b, c, d)
    call :bar, a, b, c, d
  end
  def bar(a, b, c, d)
    set [a], [b]
    set [c], [d]
  end


  define_functions

  set_label :main
  call :foo, 1, :b, 3, 4
end