module R16
  ## ABI compatible function calls
  #
  # https://github.com/0x10cStandardsCommittee/0x10c-Standards/blob/master/ABI/Draft_ABI_1.txt
  #
  module FunctionCalls
    COMMENT = "ABI_1"
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
      args.each_with_index do |arg,i|
        if i<3
          set push, R[REGISTERS[i]], COMMENT
          set R[REGISTERS[i]], op(arg).to_s, COMMENT
        else
          set push, op(arg).to_s,COMMENT
        end
      end
      jsr name
      add :sp, args.size-3, COMMENT if args.size>3
      args.size.times.to_a.reverse.each do |i|
        if i<3
          set R[REGISTERS[i]], pop, COMMENT
        else
          set :x, pop, COMMENT
        end
      end
    end

    private

    def function_prolog(args, name)
      set push, :j, COMMENT
      set :j, :sp, COMMENT
      sub :sp, args[:locals], COMMENT unless args[:locals].nil?

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
      set :a, ret_val,COMMENT  unless ret_val.nil?
      set :sp, :j, COMMENT
      set :j, pop, COMMENT
      set :pc, pop, COMMENT
    end
  end
end