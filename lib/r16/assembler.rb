require 'r16/operands'
require 'r16/labels.rb'
require 'r16/asm_output.rb'
require 'r16/function_calls.rb'
require 'r16/controls.rb'
require 'r16/video.rb'



module R16
  REGISTERS = [ :A, :B, :C, :X, :Y, :Z, :I, :J, :SP, :PC, :OV]
  R         = {}

  class Assembler
    include R16::Labels
    include R16::AsmOutput
    include R16::Operands
    include R16::FunctionCalls
    include R16::ControlStructures

    include R16::Video


    def initialize
      REGISTERS.each do |r|
        R[r.to_s.downcase.to_sym] = R[r] = Register.new r
      end
      @call_stack = []
    end

    def self.data &block

    end

    def self.code &block
      asm = Assembler.new
      asm.open_scope "code"
      asm.instance_eval &block
      asm.close_scope
    end


    def dat *args
      s = []
      args.each do |arg|
        s << case arg
               when String then "\"#{arg}\""
               when Fixnum then "0x%04x" % arg
               else arg
             end
      end
      puts "dat #{s.join(", ")}"
    end
  end
end