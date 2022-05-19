defmodule Mazes.CellComponent do
  use Phoenix.LiveComponent

  alias Mazes.Compass

  def render(assigns) do
    ~H"""
    <div class={classes(@cell, @highlighted)}>
      <%= @text %>
    </div>
    """
  end

  defp classes(cell, highlighted) do
    ["cell"] ++
      (Compass.directions()
       |> Enum.filter(fn d -> !cell[d] end)
       |> Enum.map(fn d -> "wall-#{d}" end)) ++
      [if(highlighted, do: "highlighted", else: "")]
  end
end
