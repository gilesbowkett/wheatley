# basic means fundamental. usually implies easy, we'll see about that.
%w{rubygems ap}.each {|lib| require lib}
require File.dirname(__FILE__) + "/../lib/johnson_translator"

def log_tree(tree)
  puts tree.ai
end

class EpicTowelie
  class << self
    attr_accessor :literals
    STUPID_DEFAULT_FUNCTION_NAME = "asdf"
    STUPID_DEFAULT_ARGUMENT_NAME = "qwerty"

    def create_wrapper_function(code)
      Johnson::Translator.new.translate(refactor_sexp(Johnson::Parser.parse(code).to_sexp)).to_js + "\n"
    end
    def wrap_function_call_in_a_function_definition(statement)
      [[:func_expr, STUPID_DEFAULT_FUNCTION_NAME, [], statement]]
    end
    # TODO: look how all these functions get an Array arg!! this shit should live on Array!!!
    def add_function_call(sexp)
      extract_literal(sexp)
      sexp << [:function_call,
        [[:name, STUPID_DEFAULT_FUNCTION_NAME],
         self.literals]]
    end
    # TODO: this method name is too general. probably instead, all these methods move to Array,
    # and this becomes something like Array::Refactorings.wrapper_function
    def refactor_sexp(sexp)
      sexp = wrap_function_call_in_a_function_definition(sexp)
      sexp = replace_literal_with_variable(sexp)
      sexp = add_function_call(sexp)
      sexp
    end
    def extract_literal(sexp)
      self.literals ||= []
      sexp.each do |subtree|
        if subtree.leaf?
          self.literals = subtree if subtree.is_a?(Array) && :str == subtree[0]
        else
          extract_literal(subtree)
        end
      end
      return self.literals
    end
    def replace_literal_with_variable(statement) # TODO: FUCKED
      extract_literal(statement)
      ghetto_collect = []
      statement.each_with_index do |subtree, index|
        if subtree.leaf?
          if subtree.is_a?(Array) && self.literals == subtree
            ghetto_collect << [:name, STUPID_DEFAULT_ARGUMENT_NAME]
          elsif :func_expr == subtree
            ghetto_collect << subtree
            statement[index + 2] = [STUPID_DEFAULT_ARGUMENT_NAME]
          else
            ghetto_collect << subtree
          end
        else
          ghetto_collect << replace_literal_with_variable(subtree)
        end
      end
      ghetto_collect
    end

    def parse_tree(code)
      Johnson::Parser.parse(code).value.collect {|node| node.to_sexp}
    end
  end
end

class Array

  # TODO: cleanup, the test is in array_intersection.rb
  def intersection(arr2)
    self_sorted = self.sort {|a, b| a.to_s <=> b.to_s}
    target_sorted = arr2.sort {|a, b| a.to_s <=> b.to_s}
    intersection= []
    jstart=0
    for i in (0..self_sorted.length-1)
      for j in (jstart..target_sorted.length-1)
        if self_sorted[i] == target_sorted[j]
          jstart = j+1
          intersection[intersection.length] = self_sorted[i]
          break
        end
      end
    end
    return intersection
  end

  def similarity(other)
    ((self.intersection(other).size.to_f / self.size.to_f) * 100).to_i
  end

  def token_diff(other)
    shortest, longest = [self, other].sort {|a,b| a.size <=> b.size}
    # to get the differing token, do longest.flatten - shortest.flatten ; OR!! vice versa
    (longest.flatten - shortest.flatten).size
  end

  def extract_differing_tokens(other)
    shortest, longest = [self, other].sort {|a,b| a.size <=> b.size}
    log_tree(longest.flatten - shortest.flatten)
    longest.flatten - shortest.flatten
  end

  def echoes(options)
    echo = {}
    self.each_with_index do |tree, index|
      next if echo.values.detect {|array| array.include?(tree)}

      echoes_for_this_tree = (self[(index + 1)..-1].collect do |other|
        next if echo.has_key?(tree) && echo[tree].detect {|value| value.flatten == other.flatten}
        other if tree.token_diff(other) <= options[:tokens]
      end).compact

      echo[tree] = echoes_for_this_tree unless echoes_for_this_tree.empty?
    end
    return echo
  end

  def variant_tokens
    simple_case_echoes = self.echoes(:tokens => 1)
    key = simple_case_echoes.keys[0]
    value = simple_case_echoes[key][0]
    return [(key.flatten - value.flatten)[0], (value.flatten - key.flatten)[0]]
  end

  def invariant_tokens
    simple_case_echoes = self.echoes(:tokens => 1)
    key = simple_case_echoes.keys[0]
    value = simple_case_echoes[key][0]
    variant_tokens_translated = self.variant_tokens
    return key.flatten & value.flatten
  end
end