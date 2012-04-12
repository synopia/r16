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
      class ::Fixnum
        def to_h
          "0x%04x" % to_s
        end
      end

      def op(a, b=nil)
        unless b.nil?
          return Expr.new op(a), op(b)
        end
        case a
          when Array then Pointer.new op(*a)
          when Fixnum then a.to_h
          when Symbol then Constants::R[a].nil? ? label(a) : Constants::R[a]
          else a
        end
      end

      class Expr
        def initialize (*args)
          @args = args
        end

        def to_s
          @args.collect { |arg| arg.to_s }.join("+")
        end

      end
      class Register
        def initialize (reg)
          @reg = reg
        end

        def to_s
          @reg.to_s
        end
      end

      class Pointer
        def initialize( target )
          @target = target
        end

        def to_s
          "[#{@target.to_s}]"
        end
      end
    end
  end
end