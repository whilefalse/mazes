defmodule Mazes.SuccessComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div class={"success #{if @visible, do: "", else: "hidden"}"}>
    🎉
    </div>
    """
  end
end
