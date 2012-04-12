require 'asm'

Assembler.new.code do
  class << self
      include R16::Memory   # include modules with functions
  end

  set :pc, :main            # plain jump to label (notice: forward definition)
  dat :hallo, "Hallo"       # you write ruby -> you can do offline calculations on the fly here
  colored_text :funky, 0xD000, "Funky" # some helpers for color stuff

  def foo a                 # use normal defs as functions
    set [a], a              # anything in [] means read/write to memory
  end

  declare_function :foo,        :mapping=>1 # declare a function with 1 argument
  declare_function :memcpy,     :mapping=>3 # declare an external function with 3 arguments
  declare_function :inl_memcpy, :inline=>true, :method=>:memcpy
                                            # declare a function as inline -> functions gets "unrolled"

  define_functions          # generate all declared functions

  set_label :main           # local label, this becomes sth like :_code__main, depending on the current scope
  set  :x, 0x8000
  call :foo, :x             #

  call :memcpy, 0x8000, :funky, 5 # call function, you may use labels in here

  set :a, 0x8010
  set :b, :hallo
  set :c, 5
  call :inl_memcpy,:a, :b, :c        # unroll inline function

  brk
end

