module R16
  ##
  # Writes out opcodes to assembler
  #

  module DCPU16Assembler
    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def append_opts  opts=nil
        if opts
          return "; "+opts[:comment] if opts[:comment]
        end
        ""
      end
      def out a, opts=nil
        res = "  "*@tab.level
        res += a + append_opts(opts)
        puts res
      end

      Opcodes::InstanceMethods::OPCODES_2.each do |opcode|
        define_method( opcode ) do |a, b, c=nil|
          out "#{opcode.to_s.upcase} #{op(a).to_s}, #{op(b).to_s} ", c
          super
        end
        end
      Opcodes::InstanceMethods::OPCODES_1.each do |opcode|
        define_method( opcode ) do |a, c=nil|
          out "#{opcode.to_s.upcase} #{op(a).to_s}", c
          super
        end
      end

      Opcodes::InstanceMethods::OPCODES_0.each do |opcode|
        define_method(opcode) do
          opcode.to_s.upcase
        end
      end

      def set a, b, c={}
        a_s = op(a).to_s
        b_s = op(b).to_s
        out "SET #{a_s}, #{b_s} ", c if a_s!=b_s
        super

      end
    end
  end
end