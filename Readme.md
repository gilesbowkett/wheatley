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
  + Discover code blocks which are similar to a given code block
  + Identify arbitrary similar code blocks within a JavaScript code base
  + Calculate similarity percentage between any two code blocks
  + Compare code blocks to see how many specific tokens they differ by
  + Extract the variant tokens by which similar code blocks differ
  + Extract a literal from a simple function
  + Create function calls
  + Create wrapper functions

Johnson Extension
-----------------

Wheatley would be impossible without a terrific project called Johnson.

http://ajaxian.com/archives/johnson-wrapping-javascript-in-a-loving-ruby-embrace-and-arax

https://github.com/jbarnette/johnson

Johnson embeds a JavaScript interpreter in Ruby, allowing you to write your JavaScript specs in Ruby. Johnson exposes its JavaScript interpreter's abstract syntax tree, but does not provide any methods to edit that tree. You can call `to_js` on arbitrary Johnson nodes, but you can't edit the tree and call `to_js` on the new tree you've created. Wheatley fixes this.

Since I don't know C, and I wasn't interested in exploring the Visitor pattern - I prefer to treat trees as lists when I can - I did something a bit mental with this. Wheatley generates new Johnson abstract syntax trees by creating Ruby code as strings and evaluating them. Code is data, and data is code.

Unreleased Features And/Or Sibling Project
------------------------------------------

Wheatley began as part of a very ambitious initiative, to create a web business which automatically refactors bad code for a flat fee. (I may actually complete this project, but it's on hold for now.) The original messier private repo has a bunch of additional code which analyzes every line of JavaScript in a code base and identifies duplicate and highly similar functions. I ran it against a legacy code base with 14,551 lines of code and results looked accurate.

That code shares very little code with Wheatley. It runs on Ruby, JavaScript, JSLint, Node, Sibilant, and Redis. Although Wheatley copies that code's features, using Node (and Redis) means the code runs **much** faster. Also, Wheatley has no code to systematically analyze every line of code in a code base, whereas the original project does.

It would be unrealistic to claim I have a roadmap for this project, but if I did, releasing that code would be on it. It may arrive as a feature of Wheatley or as a sibling project.

Name
----

Wheatley gets its name from a pretty dumb AI in the video game Portal 2.

http://en.wikipedia.org/wiki/Wheatley_(Portal)

Like its namesake, Wheatley is a pretty dumb AI. I say this partly because the project's business goal was so ambitious that almost anything seems dumb by comparison, but also because it's really only proof-of-concept status at this point.

