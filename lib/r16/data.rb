module R16
  module Data
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

    def fill (label, word, number)
      dat label, number.times.to_a.collect{|i|word}
    end

  end
end