module R16
  ##
  # Some very basic and probably really stupid helpers for control structures (if, while, do)
  #
  #
  module ControlStructures
    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def if_then expr, &block
        open_scope :if_then
        set_label :loop, :deindent=>1

        instance_eval &expr
        set :pc, local_label(:then)
        set :pc, local_label(:exit)
        set_label :then, :deindent=>1
        instance_eval &block
        set_label :exit, :deindent=>1

        close_scope
      end

      def while_do expr, &block
        open_scope :while_do
        set_label :loop, :deindent=>1

        instance_eval &expr
        set :pc, local_label(:exit)
        instance_eval &block
        set :pc, :loop

        set_label :exit, :deindent=>1
        close_scope

      end

      def do_while expr, &block
        open_scope :do_while
        set_label :loop, :deindent=>1

        instance_eval &block
        instance_eval &expr
        set :pc, :loop
        close_scope
      end

    end

  end
end