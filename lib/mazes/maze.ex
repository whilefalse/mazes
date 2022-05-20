defmodule Mazes.Maze do
  @moduledoc """
  Module for handling maze related types, and logic for generating mazes.
  """
  alias Mazes.Compass

  @typedoc """
  Represents a cell in the maze.

  For example, `%{N: true, S: true}` represents a cell with passages open to the North and South,
  and with walls to the West and East.
  """
  @type cell :: %{Compass.direction() => boolean()}

  @typedoc """
  Represents an x,y coordinate
  """
  @type coord :: {non_neg_integer(), non_neg_integer()}

  @typedoc """
  Represents a full maze, which is a map of coordinates to cells.
  """
  @type t :: %{coord() => cell()}

  @doc """
  Generates a random square maze of the given size using the recursive backtracking algorithm.

  See https://weblog.jamisbuck.org/2010/12/27/maze-generation-recursive-backtracking
  """
  @spec generate(pos_integer()) :: Maze.t()
  def generate(size) do
    initial_grid =
      Stream.flat_map(0..(size - 1), fn x ->
        Stream.map(0..(size - 1), fn y ->
          {{x, y}, %{}}
        end)
      end)
      |> Map.new()

    recursive_carve_passage(initial_grid, {0, 0}, size)
  end

  @spec recursive_carve_passage(Maze.t(), Maze.coord(), integer()) :: Maze.t()
  defp recursive_carve_passage(grid, {curr_x, curr_y} = curr_corrd, size) do
    Compass.directions()
    |> random().shuffle()
    |> Enum.reduce(grid, fn dir, acc ->
      next_coord = {
        curr_x + Compass.dx(dir),
        curr_y + Compass.dy(dir)
      }

      if in_bounds?(next_coord, size) and Map.get(acc, next_coord) == %{} do
        new_grid =
          acc
          |> put_in([curr_corrd, dir], true)
          |> put_in([next_coord, Compass.opposite(dir)], true)

        recursive_carve_passage(new_grid, next_coord, size)
      else
        acc
      end
    end)
  end

  defp in_bounds?({x, y}, size) do
    x >= 0 and x < size and y >= 0 and y < size
  end

  defp random(), do: Application.get_env(:mazes, :random)
end
