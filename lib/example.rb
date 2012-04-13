require 'asm'

Assembler.new.code do
  set :pc, :main
  class << self
      include R16::Memory   # include modules with functions
  end

  set :pc, :main                       # plain jump to label (notice: forward definition)
  dat :r16_rules, "r16 rules"          # you write ruby -> you can do offline calculations on the fly here
  colored_text :funky, 0xD000, "Funky" # some helpers for color stuff

  declare_function :memcpy, :params=>3 # declare an external function with 3 arguments
  declare_function :main,   :locals=>3 # set one local var

  def main                  # main entry point
    n, ball_x, ball_y = locals
    n.set! 0
    ball_x.set! 15
    ball_y.set! 7

    call :memcpy, 0x8000, :funky, 5       # call function, you may use labels in here
    call :memcpy, 0x8010, :r16_rules, 9

    set_label :loop         # local label, this becomes sth like :__main__loop, depending on the current scope

    op(:a).set! (ball_y<<5)+ball_x+0x8000
    set [:a], 0x30
    op(:b).set! n%128

    if_then proc { ife :b, 0 } do
      ball_x.add! 1
    end

    n.add! 1

    set :pc, :loop
  end

  define_functions          # generate all declared functions

  brk
end

