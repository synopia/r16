module R16
  ##
  # Support for scoped labels.
  #
  #  You can reuse common labels (ie: :entry, :exit) in each scope. The outgoing "real" label is always its
  #  complete full qualified name (ie: <scope1>_<scope2>_<label>).
  #
  #  To maintain the symbols, there is a stack of scopes. Each block opens a scope, which moves to the top of
  #  the scope stack. Every scope has a list with all labels declared (=local labels) in itself.
  #
  #  To lookup a label, first the topmost scope's local label list is searched. If found we are done otherwise we
  #  search the next scope.
  #
  #  If a lookup fails, a special label (flagged as forward) is created on demand in current scope. This flag is removed
  #  as soon as the label is actually set.
  #
  #  If you try to manually redeclare a label, an exception is raised.
  #
  #  The first scope created is called the global scope. It may be accessed directly, to set global labels.
  #

  module Labels
    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def initialize
        super
        @tab = Classes::SymbolTable.new
      end

      def op a, b=nil
        res = super a,b
        if res.nil? and a.is_a? Symbol
          res = label(a)
        end
        res
      end

      def open_scope name
        @tab.open_scope name
      end

      def close_scope
        @tab.close_scope
      end

      def set_label name, opts={}
        label = @tab.new_label name, :label, :label, opts
        out ":#{label.to_fq}", opts
      end

      def label name
        label = @tab.find name
        return label.to_fq unless label.nil?
        label = @tab.new_label name, :label, :label, :forward=>true
        label.to_fq
      end

    end

    module Classes
      class Label
        attr_reader :name
        def initialize scope, name, kind, type
          @scope = scope
          @name = name
          @kind = kind
          @type = type
          @forward = false
        end

        def set_forward
          @forward = true
        end
        def remove_forward
          @forward = false
        end
        def forward?
          @forward
        end

        def to_fq
          "#{@scope.to_fq}__#{name}".to_sym
        end
      end
      class Scope
        attr :prev

        attr_reader :name
        attr_reader :locals
        attr_reader :level

        def initialize prev, name, level
          @blocked_names = {}
          @prev = prev
          @name = prev.nil? ? name : prev.get_free_name(name)
          @level = level
          @locals = {}
        end

        def get_free_name name
          res = nil
          if @blocked_names.has_key? name
            b = @blocked_names[name]
            res = "#{name}_#{b}"
            @blocked_names[name] += 1
          else
            @blocked_names[name] = 0
            res = name
          end
          res
        end

        def find name
          return @locals[name] if @locals.has_key? name
          nil
        end

        def add_label label
          @locals[label.name] = label
        end

        def to_fq
          s = @name
          p = @prev
          until p.nil?
            s = "#{p.name}_#{s}"
            p = p.prev
          end
          s
        end
      end

      class SymbolTable
        def initialize
          @top_scope    = @global_scope = Scope.new nil, "", 0
          @stack        = []
        end

        def level
          @top_scope.level
        end

        def open_scope name
          @top_scope = Scope.new @top_scope, name, @top_scope.level+1
          @stack.push @top_scope
        end

        def close_scope
          error( "No scope to close" ) if @top_scope.nil? || @stack.size<=0
          @top_scope = @top_scope.prev
          @stack.pop
        end

        def new_label name, kind, type, opts={}
          obj = Label.new @top_scope, name, kind, type
          obj.set_forward if opts[:forward]

          scope = opts[:global] ? @global_scope : @top_scope
          old   = scope.find name
          if old.nil?
            scope.add_label obj
          else
            if old.forward?
              obj.remove_forward
            else
              raise( "#{name} already declared in #{global ? "global":"local"} scope!")
            end
          end
          obj
        end

        def find name
          scope = @top_scope
          while !scope.nil?
            res = scope.find name
            return res unless res.nil?
            scope = scope.prev
          end
        end

      end


      private
    end
  end
end