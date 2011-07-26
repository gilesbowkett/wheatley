%w{rubygems ap}.each {|lib| require lib}
require File.dirname(__FILE__) + "/../lib/basic.rb"

describe "simplest-case automated refactoring" do

  it "refactors code" do
    @code = <<-CODE
function() {
  for (var i = 0 ; i++ ; i < 100) {
    console.log("foo");
  }
  for (var i = 0 ; i++ ; i < 100) {
    console.log("bar");
  }
  for (var i = 0 ; i++ ; i < 100) {
    console.log("baz");
  }
}
    CODE
    @refactored = <<-REFACTORED
function() {
  var asdf = function(qwerty) {
    for (var i = 0 ; i++ ; i < 100) {
      console.log(qwerty);
    }
  };
  asdf("foo");
  asdf("bar");
  asdf("baz");
}
    REFACTORED
    # EpicTowelie.refactor(@code).should == @refactored
  end

  it "obtains the parse tree" do
    @parse_tree = [[:function_call,
                    [[:dot_accessor,
                     [:name, "log"],
                     [:name, "console"]],
                    [:str, "foo"]]]]
    @code = "console.log('foo');"
    EpicTowelie.parse_tree(@code).should == @parse_tree
  end

  it "identifies repetition in the parse tree" do
    @parse_tree = EpicTowelie.parse_tree("function foo() { return true; }; function foo() { return true; };")

    @parse_tree[0].should == [:func_expr, "foo", [], [[:return, [:true]]]]
    @parse_tree[1].should == [:func_expr, "foo", [], [[:return, [:true]]]]

    @parse_tree[0].should == @parse_tree[1]
    @parse_tree[0].similarity(@parse_tree[1]).should == 100
  end

  it "calculates similarity" do
    @parse_tree = EpicTowelie.parse_tree("function foo() { return true; }; function bar() { return true; };")
    @parse_tree[0].similarity(@parse_tree[1]).should == 75
  end

  it "can compare code blocks to see how many tokens they differ by" do
    @parse_tree = EpicTowelie.parse_tree("console.log('foo'); console.log('foo');")
    @parse_tree[0].token_diff(@parse_tree[1]).should == 0

    @parse_tree = EpicTowelie.parse_tree("console.log('foo'); console.log('bar');")
    @parse_tree[0].token_diff(@parse_tree[1]).should == 1

    @parse_tree = EpicTowelie.parse_tree("console.log('foo'); alert(console.log('foo'));")
    @parse_tree[0].token_diff(@parse_tree[1]).should == 1

    @parse_tree = EpicTowelie.parse_tree("console.log('foo'); alert(console.log('bar'));")
    @parse_tree[0].token_diff(@parse_tree[1]).should == 2
  end

  it "can take a given code block and discover similar code blocks" do
    @parse_tree = EpicTowelie.parse_tree("console.log('foo'); console.log('bar');")
    @parse_tree.echoes(:tokens => 1).should == {@parse_tree[0] => [@parse_tree[1]]}

    @parse_tree = EpicTowelie.parse_tree("console.log('foo'); console.log('bar'); console.log('baz');")
    @parse_tree.echoes(:tokens => 1).should == {@parse_tree[0] => [@parse_tree[1], @parse_tree[2]]}
    # TODO: this requires significant expansion, including :tokens => 2, :tokens => n, and :percentage => n
  end

  it "can extract the variant tokens" do
    @variant_tokens = EpicTowelie.parse_tree("console.log('foo'); console.log('bar');").variant_tokens
    @variant_tokens.should == ["foo", "bar"]
  end

  it "can identify the invariant tokens" do
    @invariant_tokens = EpicTowelie.parse_tree("console.log('foo'); console.log('bar');").invariant_tokens
    @invariant_tokens.should == [:function_call, :dot_accessor, :name, "log", "console", :str]
  end

  it "is possible to create arbitrary shit in Johnson" do
    Johnson::Nodes::SourceElements.new(0, 0, [Johnson::Nodes::String.new(0, 0, "foo")]).to_js.should == '"foo";'
  end
  # TODO: it'd make so much code so much easier to read if I created a wrapper method around these Johnson.new
  # statements, e.g., j.source.string("foo")

  # TODO: refactor this; it should probably live in its own describe block. currently this spec walks an array
  # through each of its transformations on the path from clunky function to refactored version
  it "can transform sexp arrays to create a wrapper function" do
    # console.log("foo");
    statement = [[:function_call,
                 [[:dot_accessor,
                   [:name, "log"],
                   [:name, "console"]],
                  [:str, "foo"]]]]

    # function asdf() {
    #   console.log("foo");
    # }
    wrapped = [[:func_expr,
                "asdf",
                [],
                [[:function_call,
                  [[:dot_accessor,
                    [:name, "log"],
                    [:name, "console"]],
                   [:str, "foo"]]]]]]

    EpicTowelie.wrap_function_call_in_a_function_definition(statement).should == wrapped

    # "foo"
    EpicTowelie.extract_literal(wrapped).should == [:str, "foo"]

    with_literal = [[:func_expr,
                     "asdf",
                     [],
                     [[:function_call,
                       [[:dot_accessor,
                         [:name, "log"],
                         [:name, "console"]],
                        [:str, "foo"]]]]]]

    with_variable = [[:func_expr,
                      "asdf",
                      ["qwerty"],
                      [[:function_call,
                        [[:dot_accessor,
                          [:name, "log"],
                          [:name, "console"]],
                         [:name, "qwerty"]]]]]]

    EpicTowelie.replace_literal_with_variable(with_literal).should == with_variable
    # TODO: consider: if these methods lived on Array, they could be chained like jQuery

    # function asdf(qwerty) {
    #   console.log(qwerty);
    # }
    # asdf("foo");
    plus_function_call = [[:func_expr,
                           "asdf",
                           ["qwerty"],
                           [[:function_call,
                             [[:dot_accessor,
                               [:name, "log"],
                               [:name, "console"]],
                              [:name, "qwerty"]]]]],
                            [:function_call,
                              [[:name, "asdf"],
                               [:str, "foo"]]]]

    EpicTowelie.add_function_call(with_variable).should == plus_function_call

    # putting it all together...
    EpicTowelie.refactor_sexp(statement).should == plus_function_call
  end

  it "can do an ultra-simple refactor, namely creating a wrapper function" do
    @code = <<-CODE
console.log("foo");
    CODE
    @refactored = <<-REFACTORED
function asdf(qwerty) {
  console.log(qwerty);
}
asdf("foo");
    REFACTORED
    EpicTowelie.create_wrapper_function(@code).should == @refactored
  end

  it "can do multiple ultra-simple refactors, namely creating wrapper functions" do
    @code = <<-CODE
console.log("foo");
    CODE
    @refactored = <<-REFACTORED
function asdf(qwerty) {
  console.log(qwerty);
}
asdf("foo");
    REFACTORED
    EpicTowelie.create_wrapper_function(@code).should == @refactored

    @code = <<-CODE
console.log("bar");
    CODE
    @refactored = <<-REFACTORED
function asdf(qwerty) {
  console.log(qwerty);
}
asdf("bar");
    REFACTORED
    EpicTowelie.create_wrapper_function(@code).should == @refactored
  end
end

