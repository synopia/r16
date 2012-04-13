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

      def open_scope name
        super
        regs.open_scope
      end

      def close_scope
        regs.close_scope
        super
      end

      def define_functions
        @functions.each do |name, func|
          @current_func = name
          func.define
        end
      end

      def call name, *args
        @functions[name].call_func *args
      end

      def locals
        @functions[@current_func].get_locals
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
        def initialize target, opts
          super target
          @reg = opts[:bound_to]
          @rescue = opts[:rescue]
        end
        def before_call arg
          if @rescue
            set push, R[@reg]
            set R[@reg], op(arg).to_s
          end
        end
        def after_call arg
          if @rescue
            set R[@reg], pop
          end
        end
        def get_arg
          Constants::R[@reg]
        end
        def to_s
          "reg_param #{@reg}#{@rescue?"[rescued]":""}"
        end
      end
      class StackParameter < CatchAllDelegateOpcode
        def initialize target, opts
          super target
          @pos = opts[:position]
        end
        def before_call arg
          set push, op(arg).to_s
        end
        def after_call arg
        end
        def get_arg
          [R[:J],(@pos>=0 ? @pos : 0x10000+@pos)]
        end
        def to_s
          "stack_param #{@pos}"
        end
      end
      class Function < CatchAllDelegateOpcode
        DEFAULT_REG =
            [{},
             {:type=>:register, :bound_to=>:a, :rescue=>true},
             {:type=>:register, :bound_to=>:b, :rescue=>true},
             {:type=>:register, :bound_to=>:c, :rescue=>true},
            # position based on J, J -> old J, J+1 -> jsr ret, J+2.. -> parameters
             {:type=>:stack,    :position=>2},
             {:type=>:stack,    :position=>3},
             {:type=>:stack,    :position=>4},
             {:type=>:stack,    :position=>5}
            ]

        def initialize target, name, opts={}
          super target
          @name = name
          params = opts[:params] || 0
          if params.is_a? Numeric
            if params>0
              params = DEFAULT_REG[1..params]
            else
              params = DEFAULT_REG[0]
            end
          end
          @mapping = params.collect do |map|
            case map[:type]
              when :register then RegisterParameter.new self, map
              when :stack    then StackParameter.new    self, map
              else
                raise "Unknown param type #{map.inspect}"
            end
          end
          @locals = (opts[:locals]||0).times.to_a.collect do |i|
            StackParameter.new(self, :position => -i-1)
          end
        end

        def get_locals
          @locals
        end

        def call_func *args
          out "", :comment=>"call #{@name} #{@mapping.join(", "){|p| p.to_s}}"
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
          out "", :comment=>"ret"
        end

        def define
          set_label @name, :global=>true
          open_scope @name
          op(:a).reserve
          op(:b).reserve
          op(:c).reserve

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
          out "", :comment=>"function #{@name}( #{@mapping.join(", "){|p| p.to_s}} ) {"
          set push, :j
          set :j, :sp
          sub :sp, @locals.size, :comment=>"#{@locals.size} locals" unless @locals.size==0
        end
        def epilog ret_val=nil
          set :a, ret_val unless ret_val.nil?
          set :sp, :j
          set :j, pop
          set :pc, pop
          out "", :comment=> "}"
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
