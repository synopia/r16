module R16
  module Expressions
    include R16::Operands

    def self.included(base)
      #base.send :include, Classes
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end



    module ClassMethods

    end

    class Registers
      REGISTERS = [:A, :B, :C, :X, :Y, :Z, :I, :J]

      def initialize
        @regs = {}
        REGISTERS.each do |r|
          @regs[r] = { :free=>true }
        end
      end

      def find_and_reserve reg=nil
        t = find_free_target reg
        raise "No free register #{reg}" if t.nil?
        reserve_register t
        t
      end

      def open_scope
        @stack ||= []
        @stack.push @regs
        @regs = Marshal.load(Marshal.dump(@regs))
      end

      def close_scope
        @regs = @stack.pop
      end

      private
      def free_targets reg=nil
        @regs.select{ |r, tags| (reg.nil? && tags[:free]) || r==reg }
      end
      def find_free_target reg=nil
        r = free_targets(reg)
        return r.first[0] if r.size>0
        nil
      end

      def reserve_register reg
        @regs[reg][:free] = false
      end
    end

    REGS = Registers.new

    module InstanceMethods

      def regs
        REGS
      end

      def op a, b=nil
        res = super
        case res
          when Operands::InstanceMethods::Assign then res.set_ref self; res.build
          when Symbol then Operands::InstanceMethods::Literal.new res
          when FunctionCalls::Classes::RegisterParameter then op(res.get_arg)
          when FunctionCalls::Classes::StackParameter then op(res.get_arg)
          else
            res
        end
      end

    end
    module Root
      def set_ref ref
        @ref = ref
      end
      def regs
        REGS
      end
      def set! other
        Operands::InstanceMethods::Assign.new self, other
      end
      def add! other
        Operands::InstanceMethods::Assign.new self, self+other
      end
      def sub! other
        Operands::InstanceMethods::Assign.new self, self-other
      end

      def + other
        Operands::InstanceMethods::Expr.new :add, self, other
      end
      def - other
        Operands::InstanceMethods::Expr.new :sub, self, other
      end
      def / other
        Operands::InstanceMethods::Expr.new :div, self, other
      end
      def * other
        Operands::InstanceMethods::Expr.new :mul, self, other
      end
      def << other
        Operands::InstanceMethods::Expr.new :shl, self, other
      end
      def >> other
        Operands::InstanceMethods::Expr.new :shr, self, other
      end
      def op(a, b=nil)
        @ref.op a, b
      end
    end


    module ::R16::Operands::InstanceMethods
      class Assign
        include Root

        def initialize left, right
          @left = left
          @right = right
        end

        def set_ref ref
          super
          @left = op(@left)
          @right = op(@right)
          @right.set_ref ref
        end

        def build
          @ref.out "", :comment=>"#{@left} = #{@right}"
          regs.open_scope
          r = @right.get_read_op @left
          set_l = @left.get_write_op.to_s
          get_r = r.to_s
          @ref.set set_l, r.to_s if set_l!=get_r
          regs.close_scope
        end
      end

      class Expr
        include Root


        def initialize op, left, right
          @op   = op
          @left = left
          @right = right
        end

        def set_ref ref
          super
          @left = op(@left)
          @right = op(@right)
          @left.set_ref ref
          @right.set_ref ref
        end

        def get_read_op target=nil
          target = R16::Constants::R[regs.find_and_reserve] if target.nil?
          l = @left.get_read_op
          r = @right.get_read_op
          @ref.set target.get_write_op, l.get_read_op  if target.get_write_op!=l.get_read_op
          @ref.send @op, target.get_write_op, r.get_read_op
          target
        end

        def to_s
          "(#{@left} #{@op} #{@right})"
        end
      end

      class Register
        include Root

        def get_read_op t=nil
          self
        end

        def get_write_op
          self
        end

        def reserve
          regs.find_and_reserve @reg
          self
        end

      end

      class Literal
        include Root

        def get_read_op t=nil
          self
        end
        def get_write_op
          self
        end
      end

      class Pointer
        include Root

        def get_read_op t=nil
          self
        end
        def get_write_op
          self
        end
      end

      class Variable
        include Root

        def initialize pos
          @pos = pos
          @bound = false
        end

        def get_read_op t=nil
          self
        end
        def get_write_op
          self
        end

        def to_s
          "[JP-#{@pos}]"
        end
      end
    end

  end
end