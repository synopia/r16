module R16
  ##
  # Helper to generate fixed data of several kinds
  #
  #

  module Data
    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def dat (*args)
        s = []
        args.flatten.each do |arg|
          case arg
            when Symbol then set_label arg
            when String then s<<"\"#{arg}\""
            when Fixnum then s<<"0x%04x" % arg
            else s<<arg
          end
        end
        out "dat #{s.join(", ")}"
      end

      def fill (label, word, number=1)
        dat label, number.times.to_a.collect{|i|word}
      end
    end

  end
end