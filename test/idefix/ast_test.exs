defmodule Idefix.ASTTest do
  use ExUnit.Case

  alias Idefix.AST

  @ast """
       defmodule Test do
         def add(x, y) do
           x + y
         end
       end
       """
       |> AST.parse()
       |> elem(1)

  test "find_node" do
    assert {:x, _, nil} = AST.find_node(@ast, 2, 11)
    assert {:x, _, nil} = AST.find_node(@ast, 2, 12)
    assert {:y, _, nil} = AST.find_node(@ast, 2, 13)
    assert {:y, _, nil} = AST.find_node(@ast, 2, 14)
  end
end
