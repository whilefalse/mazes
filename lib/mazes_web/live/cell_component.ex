defmodule Mazes.CellComponent do
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
    ["cell"] ++
      (Compass.directions()
       |> Stream.filter(fn d -> !cell[d] end)
       |> Enum.map(fn d -> "wall-#{d}" end))
  end
end
