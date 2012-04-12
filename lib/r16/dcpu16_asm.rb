module R16
  ##
  # Writes out opcodes to assembler
  #

  module DCPU16Assembler
    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods

      def out a, opts={}
       puts a
      end

      R16::Constants::OPCODES_2.each do |opcode|
        define_method( opcode ) do |a, b, c=nil|
          out "#{opcode.to_s.upcase} #{op(a).to_s}, #{op(b).to_s} ", c
          super
        end
        end
      R16::Constants::OPCODES_1.each do |opcode|
        define_method( opcode ) do |a, c=nil|
          out "#{opcode.to_s.upcase} #{op(a).to_s}", c
          super
        end
      end

      R16::Constants::OPCODES_0.each do |opcode|
        define_method(opcode) do
          opcode.to_s.upcase
        end
      end
    end
  end
end