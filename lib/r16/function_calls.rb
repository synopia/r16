module R16
  module FunctionCalls

    def def_function (name, args)
      set_label name
      open_scope name

      new_args = function_prolog(args, name)

      send name, *new_args

      function_epilog

      close_scope
    end

    def get_local pos
      [R[:J]+(0xffff-pos-1)]
    end

    def call name, *args
      puts "; ABI conform method call to #{name}"
      args.each_with_index do |arg,i|
        if i<3
          set push, R[REGISTERS[i]], "Saving register"
          set R[REGISTERS[i]], op(arg).to_s, "Param #{i}"
        else
          set push, op(arg).to_s, "Param #{i}"
        end
      end
      jsr name
      add :sp, args.size-3, "Remove parameters" if args.size>3
      set :j, :a, "Save return value"
      args.size.times.to_a.reverse.each do |i|
        if i<3
          set R[REGISTERS[i]], pop, "Restore register"
        else
          set :x, pop, "Restore register"
        end
      end
    end

    private

    def function_prolog(args, name)
      set push, :j
      set :j, :sp
      sub :sp, args[:locals] unless args[:locals].nil?

      new_args = []
      args[:params].times do |i|
        if i<3
          new_args << R[REGISTERS[i]]
        else
          new_args << [R[:J]+(0x10000-(i-2))]
        end
      end
      new_args
    end

    def function_epilog ret_val=nil
      set :a, ret_val unless ret_val.nil?
      set :sp, :j
      set :j, pop
      set :pc, pop
    end
  end
end