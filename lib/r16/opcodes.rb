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

      Constants::REGISTERS.each do |r|
        Constants::R[r.to_s.downcase.to_sym] = Constants::R[r] = Register.new r
      end
      R16::Constants::OPCODES_2.each do |opcode|
        define_method( opcode ) do |a, b, c=nil|
        end
        end
      R16::Constants::OPCODES_1.each do |opcode|
        define_method( opcode ) do |a,c=nil|
        end
      end

      R16::Constants::OPCODES_0.each do |opcode|
        define_method(opcode) do |c=nil|
        end
      end
    end

  end
end