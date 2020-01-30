defmodule Idefix.Refactor.RenameVariableTest do
  use ExUnit.Case

  import Idefix.Refactor.RenameVariable

  test "rename" do
    doc = """
    def add(x) do
      x + 2
    end
    """

    expected = """
    def add(y) do
      y + 2
    end
    """

    expected == rename_variable(doc, {1, 9}, "y")
  end
end
