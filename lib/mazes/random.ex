defmodule Mazes.Random do
  @moduledoc """
  An implementation of `Mazes.RandomBehaviour` using the built in Erlang `:random` module.
  """
  @behaviour Mazes.RandomBehaviour

  @impl Mazes.RandomBehaviour
  def shuffle(list) do
    Enum.shuffle(list)
  end

  @impl Mazes.RandomBehaviour
  def integer_between(from, to) do
    if from > to do
      raise ArgumentError, message: "`from` is greater than `to` (#{from} > #{to})"
    end

    from + :rand.uniform(to - from + 1) - 1
  end
end
