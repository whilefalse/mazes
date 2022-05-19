defmodule Mazes.Compass do
  @dx %{N: 0, S: 0, W: -1, E: 1}
  @dy %{N: -1, S: 1, W: 0, E: 0}
  @opposite %{N: :S, S: :N, E: :W, W: :E}
  @directions Map.keys(@opposite)

  @type direction :: :N | :S | :E | :W

  @spec directions() :: [direction()]
  def directions(), do: @directions

  @spec dx(direction()) :: integer()
  def dx(direction), do: @dx[direction]

  @spec dy(direction()) :: integer
  def dy(direction), do: @dy[direction]

  @spec opposite(direction()) :: direction()
  def opposite(direction), do: @opposite[direction]
end
