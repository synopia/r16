module R16
  ##
  # Beginning of a std lib
  #

  module Memory
=begin
    def memcpy target, source, n
      # target->:a, source->:b, n->:c
      do_while proc{ifn n, 0} do
        set [target], [source]
        add target, 1
        add source, 1
        sub n, 1
      end
    end
=end

    def memcpy target, source, n
      do_while proc{ifn n, 0} do
        op([target]).set! [source]
        target.add! 1
        source.add! 1
        n.sub! 1
      end
    end
  end
end