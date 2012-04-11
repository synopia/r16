module R16
  module ControlStructures

    def while_do expr, &block
      open_scope :while_do
      set_local_label :loop

      instance_eval &expr
      set R[:PC], :exit
      instance_eval &block
      set R[:PC], :loop

      set_label :exit
      close_scope

    end

    def do_while expr, &block
      open_scope :do_while
      set_local_label :loop

      instance_eval &block
      instance_eval &expr
      set R[:PC], :loop
      close_scope
    end

  end
end