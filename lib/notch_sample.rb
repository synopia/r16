require 'asm'

Assembler.new.code do
  set :a, 0x30
  set [0x1000], 0x20
  sub :a, [0x1000]
  ifn :a, 0x10
  set :pc, :crash

  set :i, 10
  set :a, 0x2000
  set_label :loop
  set [0x2000, :i], [:a]
  sub :i, 1
  ifn :i, 0
  set :pc, :loop

  set :x, 0x4
  jsr :test_sub
  set :pc, :crash

  set_label :test_sub
  shl :x, 4
  set :pc, pop

  set_label :crash
  set :pc, :crash
end

