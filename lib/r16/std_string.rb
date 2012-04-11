
module R16
  module StdString
    def strncpy target, source, n
      do_while proc{ifn n, 0} do
        set [target], [source]
        add target, 1
        add source, 1
        sub n, 1
        ife [source], 0
        set n, 0
      end
    end

    def print x, y, str
      coord_to_addr y, x, y
      call :strncpy, y, str, 0x100
    end

    def coord_to_addr target, x, y
      set target, y
      shl target, 5
      add target, x
      add target, 0x8000
    end

  end
end

