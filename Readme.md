Wheatley
========

Wheatley refactors JavaScript semi-automatically.

Claim to Fame
-------------

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
      Wheatley.create_wrapper_function(@code).should == @refactored
    end

Features
--------

  + Wrap function definitions in wrapper functions
  + Identify similar JavaScript code blocks
  + Calculate similarity percentage between any two code blocks
  + Compare code blocks to see how many specific tokens they differ by
  + Extract the variant tokens by which similar code blocks differ
  + Extract a literal from a simple function
  + Create function calls
  + Create wrapper functions
  + Perform simplistic proof-of-concept refactoring

Johnson Extension
-----------------

Wheatley would be impossible without a terrific project called Johnson.

http://ajaxian.com/archives/johnson-wrapping-javascript-in-a-loving-ruby-embrace-and-arax

https://github.com/jbarnette/johnson

Johnson embeds a JavaScript interpreter in Ruby, allowing you to write your JavaScript specs in Ruby. Johnson exposes its JavaScript interpreter's abstract syntax tree, but does not provide any methods to edit that tree. You can call `to_js` on arbitrary Johnson nodes, but you can't edit the tree and call `to_js` on the new tree you've created. Likewise, the only way to build a tree is by parsing JavaScript - you can't build a new tree, or alter an existing one, with Johnson's API. Wheatley fixes both these problems.

I attempted to do so by modifying Johnson, but it appeared impossible without studying C and adding new functionality to Johnson's embedded JavaScript interpreter itself. Instead, Johnson's `to_sexp` method converts the Johnson abstract syntax tree to the simplest possible representation of a tree - an array which contains either elements or arrays (which themselves contain either elements or arrays, recursively, ad infinitum) - and Wheatley then travels that tree, converting the elements it finds into a giant string of Ruby code which consists of instructions to build new Johnson Nodes. It then evaluates that string and produces a new AST.

This workaround makes the Johnson Translator a bit messy, but makes for very simple code elsewhere, because although Wheatley's code analysis depends on a few monkeypatches to the Array class, it mostly runs on Ruby's standard Array methods. Since code analysis matters more to Wheatley than JavaScript AST manipulation, I'm happy with the tradeoff.

If you want to play with this project, I welcome pull requests, especially ones which enhance and extend the Johnson Translator, which is quite incomplete and can only handle a subset of JavaScript.

Unreleased Features And/Or Sibling Project
------------------------------------------

Wheatley began as part of a very ambitious initiative to create a web application which automatically refactors bad code for a flat fee. The original, messier private repo has a bunch of additional code which analyzes every line of JavaScript in a code base and identifies highly similar functions, including duplicate functions. I ran it successfully against a legacy code base with 85 files and 14,551 lines of JavaScript.

Although the code which scans entire code bases is a pretty necessary counterpart to Wheatley, at least for the use cases I envision, it's a separate project which shares very little code with Wheatley. It runs on Ruby, JavaScript, JSLint, Node, Sibilant, and Redis. It would be unrealistic to claim I have a roadmap for this stuff, but if I did, releasing that code would be on it. It may arrive as a feature of Wheatley or as a sibling project.

Ancestor
--------

Wheatley descends from an earlier experiment of mine, a Ruby code duplication detector called Towelie, which also had *very* primitive similarity detection. Wheatley's code analysis runs much faster than Towelie's, and is much more powerful, but if you're curious, Towelie shows you how you might adapt Wheatley to run against Ruby rather than JavaScript.

https://github.com/gilesbowkett/towelie/wiki

Name
----

Wheatley gets its name from a pretty dumb AI in the video game Portal 2.

http://en.wikipedia.org/wiki/Wheatley_(Portal)

Like its namesake, Wheatley (the code) is also a pretty dumb AI. I say this partly because the project's business goal was so ambitious that almost anything seems dumb by comparison, but also because it's really only proof-of-concept status at this point. It can only refactor **very** simple JavaScript automatically, and cannot invent new variable names at all.

