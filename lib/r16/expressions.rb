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
        res = super a,b
        case res
          when Operands::InstanceMethods::Assign then res.build
          when Symbol then Operands::InstanceMethods::Literal.new self, res
          when FunctionCalls::Classes::RegisterParameter then op(res.get_arg)
          when FunctionCalls::Classes::StackParameter then op(res.get_arg)
          else
            res
        end
      end

    end
    module Root
      def set! other
        Operands::InstanceMethods::Assign.new ref, self, other
      end
      def add! other
        Operands::InstanceMethods::Assign.new ref, self, self+other
      end
      def sub! other
        Operands::InstanceMethods::Assign.new ref, self, self-other
      end

      def + other
        Operands::InstanceMethods::Expr.new ref, :add, self, other
      end
      def - other
        Operands::InstanceMethods::Expr.new ref, :sub, self, other
      end
      def / other
        Operands::InstanceMethods::Expr.new ref, :div, self, other
      end
      def * other
        Operands::InstanceMethods::Expr.new ref, :mul, self, other
      end
      def << other
        Operands::InstanceMethods::Expr.new ref, :shl, self, other
      end
      def >> other
        Operands::InstanceMethods::Expr.new ref, :shr, self, other
      end
      def % other
        Operands::InstanceMethods::Expr.new ref, :mod, self, other
      end
      def op(a, b=nil)
        @ref.op a, b
      end
    end


    module ::R16::Operands::InstanceMethods
      class Assign < Operand
        include Root

        def initialize ref, left, right
          super ref
          @left = op(left)
          @right = op(right)
          build
        end

        def build
          @ref.out "", :comment=>"#{@left} = #{@right}"
          @ref.regs.open_scope
          r = @right.get_read_op @left
          set_l = @left.get_write_op.to_s
          get_r = r.to_s
          @ref.set set_l, r.to_s if set_l!=get_r
          @ref.regs.close_scope
        end
      end

      class Expr < Operand
        include Root


        def initialize ref, op, left, right
          super ref
          @op   = op
          @left = op(left)
          @right = op(right)
        end

        def get_read_op target=nil
          target = @ref.r(@ref.regs.find_and_reserve) if target.nil?
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

      class Register < Operand
        include Root

        def get_read_op t=nil
          self
        end

        def get_write_op
          self
        end

        def reserve
          ref.regs.find_and_reserve @reg
          self
        end

      end

      class Literal < Operand
        include Root

        def get_read_op t=nil
          self
        end
        def get_write_op
          self
        end
      end

      class Pointer < Operand
        include Root

        def get_read_op t=nil
          self
        end
        def get_write_op
          self
        end
      end

    end
  end
end