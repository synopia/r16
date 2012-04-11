
module R16
  module AsmOutput
    [:set, :add, :sub, :mul, :div, :mod, :shl, :shr, :and, :bor, :xor, :ife, :ifn, :ifg, :ifb].each do |opcode|
      define_method( opcode ) do |a, b, c=nil|
        puts "#{opcode.to_s.upcase} #{op(a).to_s}, #{op(b).to_s} #{";"+c unless c.nil?}"
      end

      define_method( "#{opcode}2".to_sym ) do |target, a, b|
        set R[:X], a
        send opcode, R[:X], b
        set target, R[:X]
      end
    end
    [:jsr].each do |opcode|
      define_method( opcode ) do |a|
        puts "#{opcode.to_s.upcase} #{op(a).to_s}"
      end
    end

    [:pop, :peek, :push].each do |opcode|
      define_method(opcode) do
        opcode.to_s.upcase
      end
    end


  end
end