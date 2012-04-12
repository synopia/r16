require 'r16/constants'
require 'r16/operands'
require 'r16/opcodes'
require 'r16/labels'
require 'r16/controls'
require 'r16/function_calls'
require 'r16/data'
require 'r16/video'


require 'r16/dcpu16_asm'

require 'r16/memory'
require 'r16/std_string'

class Assembler
  include R16::Opcodes
  include R16::Operands
  include R16::Labels
  include R16::FunctionCalls
  include R16::ControlStructures
  include R16::Data
  include R16::Video

  include R16::DCPU16Assembler

  def code &block
    instance_eval &block
  end

  def wait n
    while_do proc { ifn(n, 0) } do
      sub n, 1
    end
  end

  def brk
    set_label :exit
    set :pc, :exit

  end
end
