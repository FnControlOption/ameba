require "./rewriter"

class Ameba::Source
  # This class takes source code and rewrites it based
  # on the different correction actions supplied.
  class Corrector
    @line_sizes : Array(Int32)

    def initialize(code : String)
      @rewriter = Rewriter.new(code)
      @line_sizes = code.lines(chomp: false).map(&.size)
    end

    # Replaces the code of the given range with *content*.
    def replace(location, end_location, content)
      @rewriter.replace(loc_to_pos(location), loc_to_pos(end_location) + 1, content)
    end

    # Inserts the given strings before and after the given range.
    def wrap(location, end_location, insert_before, insert_after)
      @rewriter.wrap(loc_to_pos(location), loc_to_pos(end_location) + 1, insert_before, insert_after)
    end

    # Shortcut for `replace(location, end_location, "")`
    def remove(location, end_location)
      @rewriter.remove(loc_to_pos(location), loc_to_pos(end_location) + 1)
    end

    # Shortcut for `wrap(location, end_location, content, nil)`
    def insert_before(location, end_location, content)
      @rewriter.insert_before(loc_to_pos(location), loc_to_pos(end_location) + 1, content)
    end

    # Shortcut for `wrap(location, end_location, nil, content)`
    def insert_after(location, end_location, content)
      @rewriter.insert_after(loc_to_pos(location), loc_to_pos(end_location) + 1, content)
    end

    # Shortcut for `insert_before(location, location, content)`
    def insert_before(location, content)
      @rewriter.insert_before(loc_to_pos(location), content)
    end

    # Shortcut for `insert_after(location, location, content)`
    def insert_after(location, content)
      @rewriter.insert_after(loc_to_pos(location) + 1, content)
    end

    private def loc_to_pos(location : Crystal::Location | {Int32, Int32})
      if location.is_a?(Crystal::Location)
        line, column = location.line_number, location.column_number
      else
        line, column = location
      end
      @line_sizes[0...line - 1].sum + (column - 1)
    end

    # Replaces the code of the given node with *content*.
    def replace(node : Crystal::ASTNode, content)
      replace(location(node), end_location(node), content)
    end

    # Inserts the given strings before and after the given node.
    def wrap(node : Crystal::ASTNode, insert_before, insert_after)
      wrap(location(node), end_location(node), insert_before, insert_after)
    end

    # Shortcut for `replace(node, "")`
    def remove(node : Crystal::ASTNode)
      remove(location(node), end_location(node))
    end

    # Shortcut for `wrap(node, content, nil)`
    def insert_before(node : Crystal::ASTNode, content)
      insert_before(location(node), content)
    end

    # Shortcut for `wrap(node, nil, content)`
    def insert_after(node : Crystal::ASTNode, content)
      insert_after(end_location(node), content)
    end

    private def location(node : Crystal::ASTNode)
      node.location || raise "Missing location"
    end

    private def end_location(node : Crystal::ASTNode)
      node.end_location || raise "Missing end location"
    end

    # Applies all scheduled changes and returns modified source as a new string.
    def process
      @rewriter.process
    end
  end
end
