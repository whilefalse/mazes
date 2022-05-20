defmodule Mazes.CellComponent do
  @moduledoc """
  A stateful component representing a single cell in a maze.

  It's implemented this way to hugely reduce the amount of data
  sent over the wire when moving around the maze.
  """
  use Phoenix.LiveComponent

  alias Mazes.{Compass, Maze}

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class={classes(@cell)} data-h={@highlighted}>
      <%= @text %>
    </div>
    """
  end

  @spec classes(Maze.cell()) :: [String.t()]
  defp classes(cell) do
    walls =
      Compass.directions()
      |> Stream.filter(&cell[&1])
      |> Enum.map(&"wall-#{&1}")

    ["cell" | walls]
  end
end
