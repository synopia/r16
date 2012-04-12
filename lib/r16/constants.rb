module R16
  module Constants
    REGISTERS = [ :A, :B, :C, :X, :Y, :Z, :I, :J, :SP, :PC, :O]
    R         = {}

    OPCODES_2 = [:set, :add, :sub, :mul, :div, :mod, :shl, :shr, :and, :bor, :xor, :ife, :ifn, :ifg, :ifb]
    OPCODES_1 = [:jsr]
    OPCODES_0 = [:pop, :peek, :push]

  end
end