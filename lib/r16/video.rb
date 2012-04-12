module R16
  ##
  # Some video related helpers
  #

  module Video
    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def colored_text *args
        numbers = []
        curr = 0
        args.each do |arg|
          l = case arg
                when Symbol then set_label arg
                when Fixnum then curr = arg
                when String then arg.bytes.each do |c|
                  numbers<< (c.to_i + curr)
                end
              end
        end
        numbers << 0
        out "; dat #{args.join(", ")}"
        dat *numbers
      end
    end
  end
end