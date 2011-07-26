# I found Array#real_intersection on the interwebs:
#
#     http://snippets.dzone.com/posts/show/2134
#
# may refactor later to use Set instead, or something. original code used test/unit,
# so here it is. there's also a rake task to run both this test and all the specs.

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

