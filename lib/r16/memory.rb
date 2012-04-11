module R16
  module Memory
    def memcpy target, source, n
      # target->:a, source->:b, n->:c
      do_while proc{ifn :c, 0} do
        set [:a], [:b]
        add :a, 1
        add :b, 1
        sub :c, 1
      end
    end
  end
end