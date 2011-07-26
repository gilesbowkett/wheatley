# I found Array#real_intersection on the interwebs:
#
#     http://snippets.dzone.com/posts/show/2134
#
# pretty sure I should have used Set instead, or something. including the test because
# I'm hoping to refactor or clean it up at some point.

require 'test/unit'
require File.dirname(__FILE__) + "/../lib/array_intersection"

class ArrayIntersectionTests < Test::Unit::TestCase    
  def test_real_array_intersection
    assert_equal [2], [2, 2, 2, 3, 7, 13, 49] & [2, 2, 2, 5, 11, 107]
    assert_equal [2, 2, 2], [2, 2, 2, 3, 7, 13, 49].intersection([2, 2, 2, 5, 11, 107])
    assert_equal ['a', 'c'], ['a', 'b', 'a', 'c'] & ['a', 'c', 'a', 'd']
    assert_equal ['a', 'a', 'c'], ['a', 'b', 'a', 'c'].intersection(['a', 'c', 'a', 'd'])
  end
end

