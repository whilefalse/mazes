defmodule Mazes.CellComponent do
  use Phoenix.LiveComponent

  alias Mazes.Compass

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class={classes(@cell)} data-h={@highlighted}>
      <%= @text %>
    </div>
    """
  end

  defp classes(cell) do
    ["cell"] ++
      (Compass.directions()
       |> Enum.filter(fn d -> !cell[d] end)
       |> Enum.map(fn d -> "wall-#{d}" end))
  end
end
