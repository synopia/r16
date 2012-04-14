module R16
  ##
  # Defines the root hooks for all opcodes
  #
  module Opcodes
    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      include R16::Operands

      REGISTERS = [ :A, :B, :C, :X, :Y, :Z, :I, :J, :SP, :PC, :O]

      OPCODES_2 = [:set, :add, :sub, :mul, :div, :mod, :shl, :shr, :and, :bor, :xor, :ife, :ifn, :ifg, :ifb]
      OPCODES_1 = [:jsr]
      OPCODES_0 = [:pop, :peek, :push]

      def initialize
        @regs = {}
        REGISTERS.each do |reg|
          downcase = reg.to_s.downcase
          @regs[downcase.to_sym] = @regs[reg] = Register.new(self, reg)
          eval <<-EOM
def #{downcase}
  @regs[:#{downcase}]
end
def #{downcase}= a
  @regs[:#{downcase}].set! a
end
          EOM
        end
      end

      def r reg
        return @regs[reg] if @regs.has_key? reg
        nil
      end

      OPCODES_2.each do |opcode|
        define_method( opcode ) do |a, b, c=nil|
        end
        end
      OPCODES_1.each do |opcode|
        define_method( opcode ) do |a,c=nil|
        end
      end

      OPCODES_0.each do |opcode|
        define_method(opcode) do |c=nil|
        end
      end
    end

  end
end