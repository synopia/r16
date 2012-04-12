module R16
  module ControlStructures
    def if_then expr, &block
      open_scope :if_then
      set_label :loop, 1

      instance_eval &expr
      set :pc, :then
      set :pc, :exit
      set_label :then, 1
      instance_eval &block
      set_label :exit, 1

      close_scope
    end

    def while_do expr, &block
      open_scope :while_do
      set_label :loop, 1

      instance_eval &expr
      set :pc, :exit
      instance_eval &block
      set :pc, :loop

      set_label :exit, 1
      close_scope

    end

    def do_while expr, &block
      open_scope :do_while
      set_label :loop, 1

      instance_eval &block
      instance_eval &expr
      set :pc, :loop
      close_scope
    end

  end
end