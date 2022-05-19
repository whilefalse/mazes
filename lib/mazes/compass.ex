defmodule Mazes.Compass do
  @moduledoc """
  Module for operations involving compass directions.
  """
  @dx %{N: 0, S: 0, W: -1, E: 1}
  @dy %{N: -1, S: 1, W: 0, E: 0}
  @opposite %{N: :S, S: :N, E: :W, W: :E}
  @directions [:N, :S, :E, :W]

  @typedoc """
  Represents a particular compass direction, North, South, East or West.
  """
  @type direction :: :N | :S | :E | :W

  @doc """
  Returns a list of all available compass directions.

  ## Examples

    iex> Mazes.Compass.directions()
    [:N, :S, :E, :W]
  """
  @spec directions() :: [direction()]
  def directions(), do: @directions

  @doc """
  Returns the change in x position when moving the given compass direction.
  Assuming the origin is at the top left (North-West) most corner.

  ## Examples

    iex> Mazes.Compass.dx(:E)
    1

    iex> Mazes.Compass.dx(:W)
    -1

    iex> Mazes.Compass.dx(:N)
    0

    iex> Mazes.Compass.dx(:S)
    0
  """
  @spec dx(direction()) :: integer()
  def dx(direction), do: @dx[direction]

  @doc """
  Returns the change in y position when moving the given compass direction.
  Assuming the origin is at the top left (North-West) most corner.

  ## Examples

    iex> Mazes.Compass.dy(:E)
    0

    iex> Mazes.Compass.dy(:W)
    0

    iex> Mazes.Compass.dy(:N)
    -1

    iex> Mazes.Compass.dy(:S)
    1
  """
  @spec dy(direction()) :: integer
  def dy(direction), do: @dy[direction]

  @doc """
  Returns the opposite direction to the given direction.

  ## Examples

    iex> Mazes.Compass.opposite(:E)
    :W

    iex> Mazes.Compass.opposite(:W)
    :E

    iex> Mazes.Compass.opposite(:N)
    :S

    iex> Mazes.Compass.opposite(:S)
    :N
  """
  @spec opposite(direction()) :: direction()
  def opposite(direction), do: @opposite[direction]
end
