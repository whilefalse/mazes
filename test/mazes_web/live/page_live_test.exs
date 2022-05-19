defmodule MazesWeb.PageLiveTest do
  use MazesWeb.ConnCase

  import Phoenix.LiveViewTest

  setup do
    Mox.stub_with(Mazes.MockRandom, Mazes.Random)
    :ok
  end

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "class=\"maze\""
    assert render(page_live) =~ "class=\"maze\""
  end
end
