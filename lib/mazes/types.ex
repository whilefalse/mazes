defmodule Mazes.Types do
  @type cell :: %{Compass.direction() => boolean()}
  @type coord :: {integer(), integer()}
  @type maze :: %{coord() => cell()}
end
