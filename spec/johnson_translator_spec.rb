%w{rubygems ap}.each {|lib| require lib}
require File.dirname(__FILE__) + "/../lib/johnson_translator.rb"

# TODO: this is repeated several places, needs to be refactored. it'd be REAL nice to
# integrate it into RSpec's "expected/got" output. also, if expected and got are equal
# when flattened, but not equal otherwise, then it's a structural error. it'd be nice
# to have that identified in the command-line output.
def log_tree(tree)
  puts tree.ai
end

describe "an Array or a Symbol" do
  it "can identify itself as a leaf" do
    tree = [[:function_call, [[:dot_accessor, [:name, "log"],
                                              [:name, "console"]],
                              [:name, "foo"]]]]
    tree.should_not be_leaf

    leaf = [:name, "foo"]
    leaf.should be_leaf

    leaf = :function_call
    leaf.should be_leaf
  end
end

describe "Johnson::Translator can convert JavaScript-derived sexps back to Johnson ASTs" do
  it "- for example, the simple variable declaration 'var asdf;'" do

    # this is basically what I'm doing:

    # include Johnson::Nodes
    # @abstract_syntax_tree = SourceElements.new(0,
    #                                            0,
    #                                            [VarStatement.new(0,
    #                                                              0,
    #                                                              [Name.new(0,0,"asdf")])])

    # but I do it less elegantly because I'm nervous about what else might be in that module,
    # and also, let's face it, because all those useless 0s aren't exactly elegant anyway

    name = Johnson::Nodes::Name.new(0,0,"asdf")
    var_name = Johnson::Nodes::VarStatement.new(0,0,[name])
    @abstract_syntax_tree = Johnson::Nodes::SourceElements.new(0,0,[var_name])

    @abstract_syntax_tree.to_js.should == "var asdf;"
    @abstract_syntax_tree.to_sexp.should == [[:var, [[:name, "asdf"]]]]

    # TODO: make this possible:
    # Johnson::Translator.new.translate(@abstract_syntax_tree.to_sexp).should == @abstract_syntax_tree

    # until then:

    # the objects are now essentially equal, but Johnson lacks a relevant/useful concept of equal here,
    # which would enable "@foo.should == @bar", so we compare on inspect and class instead

    # (TODO: highly similar disclaimer also appears in simple_case_spec.rb. eliminate repetition)

    @translated = Johnson::Translator.new.translate(@abstract_syntax_tree.to_sexp)
    # TODO: fix == for Johnson ASTs
    @translated.class.should == @abstract_syntax_tree.class
    @translated.inspect.should == @abstract_syntax_tree.inspect
  end

  it "- for example, the string 'asdf';" do
    string = Johnson::Nodes::String.new(0,0,"asdf")
    @abstract_syntax_tree = Johnson::Nodes::SourceElements.new(0,0,[string])

    @abstract_syntax_tree.to_js.should == '"asdf";'
    @abstract_syntax_tree.to_sexp.should == [[:str, "asdf"]]

    @translated = Johnson::Translator.new.translate(@abstract_syntax_tree.to_sexp)
    # TODO: fix == for Johnson ASTs
    @translated.class.should == @abstract_syntax_tree.class
    @translated.inspect.should == @abstract_syntax_tree.inspect
  end

  it "- for example, the simple statement 'console.log(foo);'" do
    @abstract_syntax_tree = Johnson::Parser.parse("console.log(foo);")

    @abstract_syntax_tree.to_sexp.should == [
      [:function_call, [
        [:dot_accessor,
         [:name, "log"],
         [:name, "console"]],
        [:name, "foo"]]]]

    @translated = Johnson::Translator.new.translate(@abstract_syntax_tree.to_sexp)
    # TODO: fix == for Johnson ASTs
    @translated.class.should == @abstract_syntax_tree.class
    @translated.inspect.should == @abstract_syntax_tree.inspect
  end

  it "- for example, the simple statement 'console.log(\"foo\");'" do
    @abstract_syntax_tree = Johnson::Parser.parse('console.log("foo");')

    @abstract_syntax_tree.to_sexp.should == [
      [:function_call, [
        [:dot_accessor,
         [:name, "log"],
         [:name, "console"]],
        [:str, "foo"]]]]

    @translated = Johnson::Translator.new.translate(@abstract_syntax_tree.to_sexp)
    # TODO: fix == for Johnson ASTs
    @translated.class.should == @abstract_syntax_tree.class
    @translated.inspect.should == @abstract_syntax_tree.inspect
  end

  it "- for example, the smallest possible function 'function() {}'" do
    @abstract_syntax_tree = Johnson::Parser.parse("function() {}")

    @abstract_syntax_tree.to_sexp.should == [[:func_expr, nil, [], []]]

    @translated = Johnson::Translator.new.translate(@abstract_syntax_tree.to_sexp)
    # TODO: fix == for Johnson ASTs
    @translated.class.should == @abstract_syntax_tree.class
    @translated.inspect.should == @abstract_syntax_tree.inspect
  end

  it "- for example, the tiny function 'function tiny() {}'" do
    @abstract_syntax_tree = Johnson::Parser.parse("function tiny() {}")

    @abstract_syntax_tree.to_sexp.should == [[:func_expr, "tiny", [], []]]

    @translated = Johnson::Translator.new.translate(@abstract_syntax_tree.to_sexp)
    # TODO: fix == for Johnson ASTs
    @translated.class.should == @abstract_syntax_tree.class
    @translated.inspect.should == @abstract_syntax_tree.inspect
  end

  it "- by auto-generating the Johnson code to compose a simple function's AST" do
    @parsed_tiny = Johnson::Parser.parse("function tiny(foo) {console.log('foo');}")
    @built_with_johnson_classes = Johnson::Nodes::SourceElements.new(0, 0,
                                    [Johnson::Nodes::Function.new(0, 0,
                                      "tiny", ["foo"],
                                          Johnson::Nodes::SourceElements.new(0, 0,
                                            [Johnson::Nodes::FunctionCall.new(0, 0,
                                              [Johnson::Nodes::DotAccessor.new(0, 0,
                                                Johnson::Nodes::Name.new(0, 0, 'log'),
                                                  Johnson::Nodes::Name.new(0, 0, 'console')),
                                                    Johnson::Nodes::String.new(0, 0, 'foo')])]))])

    # TODO: fix == for Johnson ASTs
    @built_with_johnson_classes.class.should == @parsed_tiny.class
    @built_with_johnson_classes.inspect.should == @parsed_tiny.inspect
  end

  it "- for example, the simple function 'function tiny(foo) {console.log(\"foo\");}'" do
    @abstract_syntax_tree = Johnson::Parser.parse("function tiny(foo) {console.log('foo');}")

    @abstract_syntax_tree.to_sexp.should == [
      [:func_expr, "tiny", ["foo"], [[:function_call, [[:dot_accessor,
        [:name, "log"], [:name, "console"]], [:str, "foo"]]]]]]

    @translated = Johnson::Translator.new.translate(@abstract_syntax_tree.to_sexp)
    # TODO: fix == for Johnson ASTs
    @translated.class.should == @abstract_syntax_tree.class
    @translated.inspect.should == @abstract_syntax_tree.inspect
  end

  it "- for example, the simple function 'function tiny(foo) {console.log(foo);}'" do
    @abstract_syntax_tree = Johnson::Parser.parse("function tiny(foo) {console.log(foo);}")

    @abstract_syntax_tree.to_sexp.should == [
      [:func_expr, "tiny", ["foo"], [[:function_call, [[:dot_accessor,
        [:name, "log"], [:name, "console"]], [:name, "foo"]]]]]]

    @translated = Johnson::Translator.new.translate(@abstract_syntax_tree.to_sexp)
    # TODO: fix == for Johnson ASTs
    @translated.class.should == @abstract_syntax_tree.class
    @translated.inspect.should == @abstract_syntax_tree.inspect
  end

  it "- by auto-generating Johnson code to compose the AST for a function and the code invoking it" do
    @parsed = Johnson::Parser.parse("function tiny(foo) {console.log(foo);}\n tiny(\"asdf\");")
    @built_with_johnson = Johnson::Nodes::SourceElements.new(0, 0,
                           [Johnson::Nodes::Function.new(0, 0,
                              "tiny",
                              ["foo"],
                              Johnson::Nodes::SourceElements.new(0, 0,
                                [Johnson::Nodes::FunctionCall.new(0, 0,
                                  [Johnson::Nodes::DotAccessor.new(0, 0,
                                     Johnson::Nodes::Name.new(0, 0, 'log'),
                                     Johnson::Nodes::Name.new(0, 0, 'console')),
                                    Johnson::Nodes::Name.new(0, 0, 'foo')])])),
                            Johnson::Nodes::FunctionCall.new(0, 0,
                              [Johnson::Nodes::Name.new(0, 0, 'tiny'),
                               Johnson::Nodes::String.new(0, 0, 'asdf')])])

     # TODO: fix == for Johnson ASTs
     @built_with_johnson.class.should == @parsed.class
     @built_with_johnson.inspect.should == @parsed.inspect
  end

  it "- building the correct generated code to produce the AST for 'function tiny(foo) {console.log(foo);}\n tiny(\"asdf\");'" do
    @intended = <<-INTENDED
Johnson::Nodes::SourceElements.new(0, 0, [Johnson::Nodes::Function.new(0, 0, "tiny", ["foo"], Johnson::Nodes::SourceElements.new(0, 0, [Johnson::Nodes::FunctionCall.new(0, 0, [Johnson::Nodes::DotAccessor.new(0, 0, Johnson::Nodes::Name.new(0, 0, 'log'), Johnson::Nodes::Name.new(0, 0, 'console')), Johnson::Nodes::Name.new(0, 0, 'foo')])])), Johnson::Nodes::FunctionCall.new(0, 0, [Johnson::Nodes::Name.new(0, 0, 'tiny'), Johnson::Nodes::String.new(0, 0, 'asdf')])])
INTENDED
    @intended.chomp!
    @sexp = [[:func_expr, "tiny", ["foo"], [[:function_call, [[:dot_accessor,
              [:name, "log"], [:name, "console"]], [:name, "foo"]]]]],
            [:function_call, [[:name, "tiny"], [:str, "asdf"]]]]
    Johnson::Translator.new.build_translation(@sexp).should == @intended
  end

  it "- for example, 'function tiny(foo) {console.log(foo);}\n tiny(\"asdf\");'" do
    tiny_function = <<-TINY
function tiny(foo) {console.log(foo);}
tiny("asdf");
TINY
    @abstract_syntax_tree = Johnson::Parser.parse(tiny_function.chomp)

    @abstract_syntax_tree.to_sexp.should == [
      [:func_expr, "tiny", ["foo"], [[:function_call, [[:dot_accessor,
        [:name, "log"], [:name, "console"]], [:name, "foo"]]]]],
      [:function_call, [[:name, "tiny"], [:str, "asdf"]]]]

    @translated = Johnson::Translator.new.translate(@abstract_syntax_tree.to_sexp)
    # TODO: fix == for Johnson ASTs
    @translated.class.should == @abstract_syntax_tree.class
    @translated.inspect.should == @abstract_syntax_tree.inspect
  end

  it "- for example, 'function tiny(foo) {console.log(foo);}\ntiny(\"asdf\");'\ntiny(\"qwerty\");'" do
    tiny_function = <<-TINY
function tiny(foo) {console.log(foo);}
tiny("asdf");
tiny("qwerty");
TINY
    @abstract_syntax_tree = Johnson::Parser.parse(tiny_function.chomp)

    @abstract_syntax_tree.to_sexp.should == [
      [:func_expr, "tiny", ["foo"], [[:function_call, [[:dot_accessor,
        [:name, "log"], [:name, "console"]], [:name, "foo"]]]]],
      [:function_call, [[:name, "tiny"], [:str, "asdf"]]],
      [:function_call, [[:name, "tiny"], [:str, "qwerty"]]]]

    @translator = Johnson::Translator.new
    @translated = @translator.translate(@abstract_syntax_tree.to_sexp)
    # TODO: fix == for Johnson ASTs
    @translated.class.should == @abstract_syntax_tree.class
    @translated.inspect.should == @abstract_syntax_tree.inspect
  end
end

describe "function subnode translating" do
  it "translates function arguments" do
    @translator = Johnson::Translator.new
    @translator.translate_function_arguments([]).should == "[]"
    @translator = Johnson::Translator.new
    @translator.translate_function_arguments(["foo"]).should == "[\"foo\"]"
  end
  it "translates function names" do
    @translator = Johnson::Translator.new
    @translator.translate_function_name("tiny").should == "\"tiny\""
  end
  it "translates function bodies" do
    @sexp = [
             [:function_call, [
               [:dot_accessor,
                [:name, "log"],
                [:name, "console"]],
               [:str, "foo"]]]]
    @translator = Johnson::Translator.new
    @translator.translate_function_body(@sexp).should == %{Johnson::Nodes::SourceElements.new(0, 0, [Johnson::Nodes::FunctionCall.new(0, 0, [Johnson::Nodes::DotAccessor.new(0, 0, Johnson::Nodes::Name.new(0, 0, 'log'), Johnson::Nodes::Name.new(0, 0, 'console')), Johnson::Nodes::String.new(0, 0, 'foo')])])}
  end
end

describe "dot accessor and function call node" do
  it "fuck" do # stoned
    @abstract_syntax_tree = Johnson::Parser.parse("tiny.foo()")
    @abstract_syntax_tree.to_sexp.should == [
      [:function_call,
       [[:dot_accessor,
        [:name, "foo"],
        [:name, "tiny"]]]]]

    @translated = Johnson::Translator.new.translate(@abstract_syntax_tree.to_sexp)
    @translated.class.should == @abstract_syntax_tree.class
    @translated.inspect.should == @abstract_syntax_tree.inspect
  end

  it "two" do
    @abstract_syntax_tree = Johnson::Parser.parse("tiny.foo(); tiny.bar();")
    @abstract_syntax_tree.to_sexp.should == [
      [:function_call,
       [[:dot_accessor,
        [:name, "foo"],
        [:name, "tiny"]]]],
      [:function_call,
       [[:dot_accessor,
         [:name, "bar"],
         [:name, "tiny"]]]]]

    @translated = Johnson::Translator.new.translate(@abstract_syntax_tree.to_sexp)
    @translated.class.should == @abstract_syntax_tree.class
    @translated.inspect.should == @abstract_syntax_tree.inspect
                  # this does not work! translate_pair_node is probably fucked.
                  # TODO: maybe rename it translate_array_subtree? the problem is really right
                  # there in the names. an array subtree means a call to traverse; an array node
                  # means take it apart and turn it into JavaScript. what I really need to look
                  # at is what I do when I'm increasing my depth level on a recursive traverse() call.

                  # FIXME: not only do I have no fucking clue what the above comment means, I
                  # think it must be incorrect, because the specs pass. wtf?!
  end
end

# TODO: refactor specs into topic-grouped files
# TODO: wrapper functions for spec patterns
describe "function call nodes" do
  it "one" do
    @abstract_syntax_tree = Johnson::Parser.parse("tiny(foo)")
    @abstract_syntax_tree.to_sexp.should == [[:function_call, [[:name, "tiny"], [:name, "foo"]]]]

    @translator = Johnson::Translator.new
    @translated = @translator.translate(@abstract_syntax_tree.to_sexp)
    @translated.class.should == @abstract_syntax_tree.class
    @translated.inspect.should == @abstract_syntax_tree.inspect
  end

  it "two" do # this does not work! translate_pair_node is probably fucked.
              # TODO: maybe rename it translate_array_subtree? the problem
              # is really right there in the names. an array subtree means a call to
              # traverse; an array node means take it apart and turn it into
              # JavaScript. it's entirely possible that two function defs in a row,
              # or two tiny.foo() calls in a row, could fail in the same manner
              # and for the same reason. what I really need to look at is what I
              # do when I'm increasing my depth level on a recursive traverse() call.

              # FIXME: wtf???????????
    @abstract_syntax_tree = Johnson::Parser.parse("tiny(foo); tiny(bar);")
    @abstract_syntax_tree.to_sexp.should == [
      [:function_call,
       [[:name, "tiny"],
        [:name, "foo"]]],
      [:function_call,
       [[:name, "tiny"],
        [:name, "bar"]]]]

    @translator = Johnson::Translator.new
    @translated = @translator.translate(@abstract_syntax_tree.to_sexp)
    johnson_build =<<-CODE
Johnson::Nodes::SourceElements.new(0, 0, [Johnson::Nodes::FunctionCall.new(0, 0, [Johnson::Nodes::Name.new(0, 0, 'tiny'), Johnson::Nodes::Name.new(0, 0, 'foo')]), Johnson::Nodes::FunctionCall.new(0, 0, [Johnson::Nodes::Name.new(0, 0, 'tiny'), Johnson::Nodes::Name.new(0, 0, 'bar')])])
CODE
    @translator.translation.join("").gsub(/\), \]/, ")]").should == johnson_build.chomp
    @translated.class.should == @abstract_syntax_tree.class
    @translated.inspect.should == @abstract_syntax_tree.inspect
  end
end

describe "translating a new sexp into JavaScript" do
  sexp = [[:func_expr, "asdf", ["qwerty"], [[:function_call, [[:dot_accessor, [:name, "log"], [:name, "console"]], [:name, "qwerty"]]]]], [:function_call, [[:name, "asdf"], [:str, "foo"]]]]
  javascript = <<-CODE
function asdf(qwerty) {
  console.log(qwerty);
}
asdf("foo");
CODE
  Johnson::Translator.new.translate(sexp).to_js.should == javascript.chomp
end
