R16 - ruby to dcpu16 assembler
==============================

Basically a bunch of helper methods to generate dcpu16 code.

Here is the notch example (http://0x10c.com/doc/dcpu-16.txt):

    R16::Assembler.code do
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


Of course you can use full power of ruby. Currently there are basic functions calls (see ABI [1]), scoped labels and some
basic control structure elements (while, do-while, if, ...).

A more sophisticated example: http://www.dcpubin.com/su009GD_2

[1] https://github.com/0x10cStandardsCommittee/0x10c-Standards/blob/master/ABI/Draft_ABI_1.txt