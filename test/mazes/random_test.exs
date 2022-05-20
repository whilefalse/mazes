defmodule Mazes.RandomTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  import StreamData

  describe "shuffle/1" do
    property "contains the same elements" do
      check all(list <- list_of(binary())) do
        shuffled = Mazes.Random.shuffle(list)
        assert MapSet.new(shuffled) == MapSet.new(list)
      end
    end
  end

  describe "integer_between/2" do
    property "is >= the lower bound" do
      check all(
              lower <- integer(0..100),
              upper <- integer(lower..200)
            ) do
        random = Mazes.Random.integer_between(lower, upper)
        assert random >= lower
      end
    end

    property "is <= the upper bound" do
      check all(
              lower <- integer(0..100),
              upper <- integer(lower..200)
            ) do
        random = Mazes.Random.integer_between(lower, upper)
        assert random <= upper
      end
    end

    property "is an integer" do
      check all(
              lower <- integer(0..100),
              upper <- integer(lower..200)
            ) do
        random = Mazes.Random.integer_between(lower, upper)
        assert is_integer(random)
      end
    end
  end
end
