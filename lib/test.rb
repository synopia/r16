require 'asm'


c = Assembler.new.code do
  regs.open_scope
  x = op(:A).reserve
  y = op(:B)
  n = op(:C)

  set :a, 1
  op( n.set! (y<<5)+x/:xx+0x8000)
  op( n.add! 1 )
  regs.close_scope
  regs.open_scope

  target = op(:a).reserve
  source = op(:b).reserve
  n      = op(:c).reserve

  op( op([target]).set!( op([source]) ) )

  op( target.add! [1] )
  op( source.add! 1 )
  op( n.sub! 1 )
  regs.close_scope
end
