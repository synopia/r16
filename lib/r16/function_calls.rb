module R16
  ## ABI compatible function calls
  #
  # https://github.com/0x10cStandardsCommittee/0x10c-Standards/blob/master/ABI/Draft_ABI_1.txt
  #
  #  Generates function calls with possible unlimited parameter size (using stack for parameters).
  #
  #  First you need to declare a function. Do this at the very first of your program. Declaring does not generates
  #  any code, but creates some datastructures to manage parameter exchange.
  #
  #  Use define_functions to generate the code for all functions in place.
  #
  #  TODO local variables...
  #

  module FunctionCalls
    COMMENT = "ABI_1"

    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def declare_function( name, opts={} )
        opts[:method] ||= name
        label(name)
        if opts[:inline]
          func = Classes::InlineFunction.new self, opts[:method], opts
        else
          func = Classes::Function.new self, opts[:method], opts
        end
        @functions ||= {}
        @functions[name] = func
      end

      def define_functions
        @functions.each do |name, func|
          func.define
        end

      end

      def call name, *args
        @functions[name].call_func *args
      end
    end

    module Classes

      class CatchAllDelegateOpcode
        def initialize target
          @target = target
        end
        def method_missing method, *args
          @target.send method, *args
        end
        def self.const_missing const
          R16::Constants.const_get const
        end
      end

      class RegisterParameter < CatchAllDelegateOpcode
        def initialize target, reg
          super target
          @reg = reg
        end
        def before_call arg
          if op(@reg)==op(arg)
            out "; optimized #{@reg}"
            return
          end
          set push, R[@reg], COMMENT
          set R[@reg], op(arg).to_s, COMMENT
        end
        def after_call arg
          if op(@reg)==op(arg)
            return
          end
          set R[@reg], pop, COMMENT
        end
        def get_arg
          Constants::R[@reg]
        end
      end
      class StackParameter < CatchAllDelegateOpcode
        def initialize target, pos
          super target
          @pos = pos
        end
        def before_call arg
          set push, op(arg).to_s,COMMENT
        end
        def after_call arg
        end
        def get_arg
          [R[:J],(0x10000-(1+@pos))]
        end
      end
      class Function < CatchAllDelegateOpcode

        def initialize target, name, opts={}
          super target
          @name = name

          if opts[:mapping]
            if opts[:mapping].is_a? Fixnum
              # default ABI call layout (a, b, c, 1st on stack, 2nd on stack, ...)
              opts[:mapping] = opts[:mapping].times.to_a.collect do |i|
                i<3 ? Constants::REGISTERS[i] : i-3
              end
            end
            @mapping = opts[:mapping].collect do |map|
              case map
                when Symbol then RegisterParameter.new self, map
                else             StackParameter.new self, map
              end
            end
          end
        end

        def call_func *args
          out "; call #{@name}"
          args.each_with_index do |arg, i|
            map = @mapping[i]
            map.before_call arg
          end
          jsr @name
          add :sp, stack_params.size if stack_params.size>0
          args.each_with_index do |arg, i|
            map = @mapping[args.size-1-i]
            map.after_call arg
          end
        end

        def define
          set_label @name, :global=>true
          open_scope @name

          prolog

          args = get_args
          send @name, *args

          epilog

          close_scope
        end

        private

        def stack_params
          @mapping.each.select {|m| m.is_a? StackParameter }
        end
        def get_args
          @mapping.each.collect do |map|
            arg = map.get_arg
            arg
          end
        end

        def prolog
          set push, :j, COMMENT
          set :j, :sp, COMMENT
          #sub :sp, args[:locals], COMMENT unless args[:locals].nil? todo
        end
        def epilog ret_val=nil
          set :a, ret_val,COMMENT  unless ret_val.nil?
          set :sp, :j, COMMENT
          set :j, pop, COMMENT
          set :pc, pop, COMMENT
        end
      end

      class InlineFunction < CatchAllDelegateOpcode
        def initialize target, name, opts
          super target
          @name = name
        end
        def call_func *args
          out "; inline call #{@name}"
          send @name, *args
        end
        def define
        end
      end
    end

  end
end
