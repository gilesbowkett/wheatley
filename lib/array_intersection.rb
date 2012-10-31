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

  # from lib/basic
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
    longest.flatten - shortest.flatten
  end

  # I think this one needs a freaking diagram
  def echoes(options)
    echo = {}

    self.each_with_index do |tree, index|
      next if echo.values.detect {|array| array.include?(tree)}

      echoes_for_this_tree = (

        self[(index + 1)..-1].collect do |other|
          next if echo.has_key?(tree) && echo[tree].detect {|value| value.flatten == other.flatten}
          other if tree.token_diff(other) <= options[:tokens]
        end

      ).compact

      echo[tree] = echoes_for_this_tree unless echoes_for_this_tree.empty?
    end

    return echo
  end

  def token_variance
    simple_case_echoes = self.echoes(:tokens => 1)
    # I believe the reason this code only grabs the first element of these two arrays is because of that
    # :tokens => 1 thing. it means you're only going one level of difference deep; however, echoes
    # can actually take an arbitrary number of tokens, so this would be interesting stuff to expand on.
    key = simple_case_echoes.keys[0]
    value = simple_case_echoes[key][0]
    return key, value
  end

  def variant_tokens
    key, value = token_variance
    return [(key.flatten - value.flatten)[0], (value.flatten - key.flatten)[0]]
  end

  def invariant_tokens
    key, value = token_variance
    return key.flatten & value.flatten
  end

end

