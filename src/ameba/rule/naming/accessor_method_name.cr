module Ameba::Rule::Naming
  # A rule that makes sure that accessor methods are named properly.
  #
  # Favour this:
  #
  # ```
  # class Foo
  #   def user
  #     @user
  #   end
  #
  #   def user=(value)
  #     @user = value
  #   end
  # end
  # ```
  #
  # Over this:
  #
  # ```
  # class Foo
  #   def get_user
  #     @user
  #   end
  #
  #   def set_user(value)
  #     @user = value
  #   end
  # end
  # ```
  #
  # YAML configuration example:
  #
  # ```
  # Naming/AccessorMethodName:
  #   Enabled: true
  # ```
  class AccessorMethodName < Base
    include AST::Util

    properties do
      description "Makes sure that accessor methods are named properly"
    end

    MSG = "Favour method name '%s' over '%s'"

    def test(source, node : Crystal::ClassDef | Crystal::ModuleDef)
      defs =
        case body = node.body
        when Crystal::Def
          [body]
        when Crystal::Expressions
          body.expressions.select(Crystal::Def)
        end

      defs.try &.each do |def_node|
        # skip defs with explicit receiver, as they'll be handled
        # by the `test(source, node : Crystal::Def)` overload
        check_issue(source, def_node) unless def_node.receiver
      end
    end

    def test(source, node : Crystal::Def)
      # check only defs with explicit receiver (`def self.foo`)
      check_issue(source, node) if node.receiver
    end

    private def check_issue(source, node : Crystal::Def)
      location = name_location(node)
      end_location = name_end_location(node)

      case node.name
      when /^get_([a-z]\w*)$/
        return unless node.args.empty?
        if location && end_location
          issue_for location, end_location, MSG % {$1, node.name}
        else
          issue_for node, MSG % {$1, node.name}
        end
      when /^set_([a-z]\w*)$/
        return unless node.args.size == 1
        if location && end_location
          issue_for location, end_location, MSG % {"#{$1}=", node.name}
        else
          issue_for node, MSG % {"#{$1}=", node.name}
        end
      end
    end
  end
end
