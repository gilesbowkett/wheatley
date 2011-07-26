class Array
  # TODO: cleanup
  # this code is a bit of a fluke, it's got a test rather than a spec, see the test for
  # more info
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

  # TODO: the other Array monkeypatches probably belong in here also
end

