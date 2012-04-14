module R16
  ##
  # This module contains helpers to operate with operands for single instructions
  #
  #  * operand is an ruby Array (ie [:a])     -> use the memory of the content
  #  * operand is a number                    -> use as literal
  #  * operand is a symbol and one of [:A, :B, :C, :X, :Y, :Z, :I, :J, :PC, :SP, :O] + lowercase
  #                                           -> use as register
  #  * operand is a symbol but not a register -> operand is a label
  #
  #
  module Operands
    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods

      def op(a, b=nil)
        unless b.nil?
          return InlineExpr.new self, op(a), op(b)
        end
        case a
          when Array then Pointer.new self, op(*a)
          when Numeric then Literal.new self, a
          when Symbol then r(a).nil? ? nil : r(a)
          else a
        end
      end


      class Operand
        attr_reader :ref
        def initialize ref
          @ref = ref
        end
      end

      class InlineExpr < Operand
        def initialize( ref, a, b)
          super ref
          @args = [a, b]
        end

        def to_s
          @args.collect { |arg| arg.to_s }.join("+")
        end

      end
      class Register < Operand
        def initialize ( ref, reg)
          super ref
          @reg = reg
        end

        def to_s
          @reg.to_s
        end
      end

      class Pointer < Operand
        def initialize( ref, target )
          super ref
          @target = target
        end

        def to_s
          "[#{@target.to_s}]"
        end
      end

      class Literal < Operand
        def initialize (ref, lit)
          super ref
          @lit = lit
        end

        def to_s
          return "0x%04x" % @lit.to_s if @lit.is_a? Numeric
          @lit.to_s
        end
      end
    end
  end
end