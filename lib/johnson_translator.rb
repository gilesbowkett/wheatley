%w{rubygems johnson ap}.each {|lib| require lib}

# the Johnson Translator here is quite hacky. here's its rationale and raison d'etre. Johnson
# does not really provide any facility to create a parse tree from JavaScript, alter it, and
# then turn it back into JavaScript again. it's kind of read-only.

# sensible people recommended I create a Visitor implementation which hits every node in
# a Johnson abstract syntax tree. I went with something a bit weirder.

# my implementation gets the Johnson AST, which is basically an Arrays of Arrays and/or Symbols,
# and runs through every element in the AST, turning it into Ruby which builds a new Johnson AST.
# then I just eval() the new Ruby and create a new Johnson AST, which I can then call to_js() on.

# the advantage of this unusual approach, if there is one (and I certainly hope so), is that
# this code's designed to run with other code I've written which can identify similarity and
# repetition within a code base to within arbitrary thresholds. that code is also only semi-
# implemented, but it basically works, and is pretty awesome. I've used it against gigantic code
# bases of many thousands of lines of code. anyway, that code works with Arrays, and I didn't
# want to redo it to use Visitors, at least not yet. not until it seemed truly necessary.

# code is data, data is code.

module List
  def leaf?
    not self.detect {|element| element.is_a? Array}
  end
end

module Atom
  def leaf?
    true
  end
end

class Array
  include List
end

class Symbol
  include Atom
end

class String
  include Atom
end

module Johnson
  class Translator
    attr_accessor :translation
    # FIXME: grr!!!!!!!! refactor to spec_helper
    # TODO: figure out why I wrote the above comment
    unless "constant" == defined?(CLASS_NAMES)
      CLASS_NAMES = {
        :name => "Name",
        :str  => "String",
        :var  => "VarStatement",
        :dot_accessor => "DotAccessor",
        :function_call => "FunctionCall"
      }
    end
    def initialize(top_level = true)
      @translation = []
      @left_brackets_and_parentheses_index = 0
      if top_level
        @translation << ["Johnson::Nodes::SourceElements.new(0, 0, ["]
        @left_brackets_and_parentheses_index += 1
      end
      # that second variable is somewhat ridiculous so it needs to be excused. here is its
      # excuse: Johnson's node-building statements reliably require us (at this stage at least)
      # to tack on both a ( and a [ any time we add a symbol node.
      #
      # update: this requiring is not so reliable any more. I think I'm going to refactor this
      # so it doesn't suck. not quite sure how that'll happen just yet, though.
    end

    # TODO: this should have a test of its own (also "pair node" might be better term)
    def translate_pair_node(subtree)
      if subtree.empty?
        @translation << "Johnson::Nodes::SourceElements.new(0, 0, [])"
      else
        node_type, node_value = subtree
        @translation << "Johnson::Nodes::#{CLASS_NAMES[node_type]}.new(0, 0, '#{node_value}')"
      end
    end
    # TODO: this should have a test of its own
    def translate_symbol_node(node_type)
      @translation << "Johnson::Nodes::#{CLASS_NAMES[node_type]}.new(0, 0, ["
      @left_brackets_and_parentheses_index += 1
    end

    def translate_function_name(name)
      name.inspect
    end
    def translate_function_arguments(arguments)
      arguments.inspect
    end
    def translate_function_body(body)
      self.class.new.build_translation(body) # BALDERDASH
    end

    def traverse(sexp)
      sexp.each_with_index do |subtree, index|
        if subtree.leaf?
          case subtree
          when :dot_accessor # or: if BINARY_NODES.include?(subtree)
            @translation << "Johnson::Nodes::DotAccessor.new(0, 0, "

            # binary nodes go like initialize(line, column, left, right), so we need to
            # have the left and right bits handled. so we use slice!(index + 1) as an
            # analogue to #pop(), twice, and add in the , and the )

            translate_pair_node(sexp.slice!(index + 1))
                               # that slice!(etc) should probably be like sexp.next! or something
            @translation << ", "

            translate_pair_node(sexp.slice!(index + 1))
            @translation << "), "
          when :func_expr
            @translation << "Johnson::Nodes::Function.new(0, 0, "

            @translation << translate_function_name(sexp.slice!(index + 1))
            @translation << ", "

            @translation << translate_function_arguments(sexp.slice!(index + 1))
            @translation << ", "

            @translation << translate_function_body(sexp.slice!(index + 1))
            @translation << "), "
          when :function_call
            @translation << "Johnson::Nodes::#{CLASS_NAMES[:function_call]}.new(0, 0, ["
            @translation << self.class.new(false).build_translation(sexp.slice!(index + 1))
            @translation << "]), "
          when Symbol
            translate_symbol_node(subtree)
          when Array
            translate_pair_node(subtree)
            @translation << ", " # this necessitates the regex below
          end
        else
          traverse(subtree)
        end
      end
    end
    def close_brackets
      @translation << ("])" * @left_brackets_and_parentheses_index) # see excuse, above
      @translation.join("").gsub(/\), \]/, ")]") # TODO: write a test for this!!
    end
    def build_translation(sexp)
      traverse(sexp)
      close_brackets # this may have to happen very differently.
    end
    def translate(sexp)
      eval build_translation(sexp)
    end
  end
end

