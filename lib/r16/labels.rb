module R16
  module Labels
    class Scope
      attr_reader :prev
      attr_reader :name
      attr_reader :locals

      def initialize prev, name
        @prev = prev
        @name = prev.nil? ? name  : prev.reserve(name)
        @locals = {}
      end

      def reserve name
        @reserved ||= {}
        @reserved[name] = 0 unless @reserved.has_key? name
        @reserved[name] += 1
        (name.to_s + @reserved[name].to_s)
      end

      def def_local label
        @locals[label] = label
      end

      def get_local label, create=false
        @locals[label] if @locals.has_key? label
        if create
          @locals[label] = label
        end
        @locals[label]
      end

      def get_recursive label
        l = @locals
        p = self
        until p.nil?
          l = p.locals
          if l.has_key? label
            return p
          end
          p = p.prev
        end

        nil
      end

      def get_global_name label
        res = get_local(label)
        return local_to_global res unless res.nil?
        scope = get_recursive label
        return scope.local_to_global label unless scope.nil?
        local_to_global def_local label
      end

      def get_local_name label
        local_to_global get_local(label, true)
      end

      def local_to_global name
        s = ""
        p = self
        until p.nil? do
          s = p.name.to_s + "_" + s
          p = p.prev
        end
        "#{s}_#{name}".to_sym
      end

    end



    def open_scope name
      puts "; new scope #{name}"
      @top_scope = Scope.new @top_scope, name
    end

    def close_scope
      puts "; close scope "
      @top_scope = @top_scope.prev
    end

    def set_label name
      puts ":#{@top_scope.get_global_name name}"
    end
    def set_local_label name
      puts ":#{@top_scope.get_local_name name}"
    end

    def label name
      @top_scope.get_global_name name
    end

    private

  end
end