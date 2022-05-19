defmodule Mazes.CellComponent do
  use Phoenix.LiveComponent

  alias Mazes.Compass

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class={classes(@cell)}>
      <div class={"cell-inner" <> if(@highlighted, do: " highlighted", else: "")}>
        <%= @text %>
      </div>
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
