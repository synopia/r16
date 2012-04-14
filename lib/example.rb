require 'asm'

Assembler.new.code do
  class << self
    include R16::Memory   # include modules with functions
  end

  set :pc, :main                       # plain jump to label (notice: forward definition)
  dat :r16_rules, "r16 rules"          # you write ruby -> you can do offline calculations on the fly here
  colored_text :funky, 0xF000, "Funky" # some helpers for color stuff

  declare_function :memcpy, :params=>3 # declare an external function with 3 arguments
  declare_function :main,   :locals=>7 # set some local var
  MAX_WIDTH  = 32
  MAX_HEIGHT = 12
  MID_X      = ((MAX_WIDTH)>>1)-1
  MID_Y      = ((MAX_HEIGHT)>>1)-1

  def bounce val
    val.set! ((val-(1<<8))*0xffff) + (1<<8)
  end

  def main                  # main entry point
    locals  :n, :ball_x, :ball_y, :ball_dir_x, :ball_dir_y, :ball_screen, :new_ball_screen
    self.n= 0
    self.ball_x= MID_X << 8
    self.ball_y= MID_Y << 8
    self.ball_dir_x= (1<<8) + (1 << 4)
    self.ball_dir_y= (1<<8) + (1 << 4)

    call :memcpy, 0x8000, :funky, 5       # call function, you may use labels in here
    call :memcpy, 0x8010, :r16_rules, 9

    set_label :loop         # local label, this becomes sth like :__main__loop, depending on the current scope

    if_then proc { ifn self.new_ball_screen, self.ball_screen} do
      op([self.ball_screen]).set! 0x00
      self.ball_screen = self.new_ball_screen
      op([self.ball_screen]).set! 0xf030
    end

    self.b= n%64
    self.c = 0
    if_then proc { ife :b, 0 } do
      self.a  = self.ball_x
      self.b  = self.ball_y
      self.a += self.ball_dir_x
      self.b += self.ball_dir_y

      if_then proc { ifg (1<<8), self.a } do
        self.a = self.ball_x + (1<<8)
        bounce self.ball_dir_x
        self.c = 1
      end
      if_then proc { ifg (1<<8), self.b } do
        self.b = self.ball_y + (1<<8)
        bounce self.ball_dir_y
      end
      self.a -= (1<<8)
      self.b -= (1<<8)
      if_then proc { ifg self.a, (MAX_WIDTH<<8)-1 } do
        self.a = self.ball_x
        bounce self.ball_dir_x
        self.c = 1
      end
      if_then proc { ifg self.b, (MAX_HEIGHT<<8)-1} do
        self.b = self.ball_y
        bounce self.ball_dir_y
      end
      self.ball_x = self.a
      self.ball_y = self.b

      if_then proc { ifn :c, 0 } do
      #  self.ball_x = MID_X << 8
      #  self.ball_y = MID_Y << 8
      end

      self.new_ball_screen = ((self.ball_y>>8)<<5)+(self.ball_x>>8)+0x8000
    end

    self.n+= 1

    set :pc, :loop
  end

  define_functions          # generate all declared functions

  brk
end

