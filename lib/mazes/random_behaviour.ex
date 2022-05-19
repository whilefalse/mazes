defmodule Mazes.RandomBehaviour do
  @moduledoc """
  A behaviour for implementing required random operations for generating mazes.

  This is here so we can mock it in our tests and have deterministic tests.
  """

  @doc """
  Shuffles the given list, returning a new list with the same items in a random order.
  """
  @callback shuffle(list()) :: list()

  @doc """
  Returns a random integer between the given two integers (inclusive).
  """
  @callback integer_between(integer(), integer()) :: integer()
end
