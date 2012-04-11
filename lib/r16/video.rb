module R16
  module Video

    def colored_text *args
      numbers = []
      curr = 0
      args.each do |arg|
        l = case arg
              when Fixnum then curr = arg
              when String then arg.bytes.each do |c|
                numbers<< (c.to_i + curr)
              end
            end
      end
      numbers << 0
      puts "; dat #{args.join(", ")}"
      dat *numbers
    end
  end
end