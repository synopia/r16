module R16
  module Operands

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
        when Symbol then R[a].nil? ? label(a) : R[a]
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
        @reg
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