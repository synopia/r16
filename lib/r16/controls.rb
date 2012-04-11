module R16
  module ControlStructures
    def if_then expr, &block
      open_scope :if_then
      set_local_label :loop

      instance_eval &expr
      set :pc, :then
      set :pc, :exit
      set_local_label :then
      instance_eval &block
      set_local_label :exit

      close_scope
    end

    def while_do expr, &block
      open_scope :while_do
      set_local_label :loop

      instance_eval &expr
      set :pc, :exit
      instance_eval &block
      set :pc, :loop

      set_local_label :exit
      close_scope

    end

    def do_while expr, &block
      open_scope :do_while
      set_local_label :loop

      instance_eval &block
      instance_eval &expr
      set :pc, :loop
      close_scope
    end

  end
end