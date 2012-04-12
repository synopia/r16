
module R16
  ##
  # Beginning of a std lib
  #

  module StdString
    def strncpy target, source, n
      set :a, n
      do_while proc{ifn :a, 0} do
        set [target], [source]
        add target, 1
        add source, 1
        sub :a, 1
        ife [source], 0
        set :a, 0
      end
    end

    def println x, y, str
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

