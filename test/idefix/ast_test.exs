defmodule Idefix.ASTTest do
  use ExUnit.Case

  alias Idefix.AST

  @ast """
       defmodule Test do
         def add(x, y) do
           x + y
           test("hello there")
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

  test "find_nearest_do_block" do
    assert node = AST.find_node(@ast, 3, 9)

    assert {:do, {:__block__, _, [{:+, _, _} | _]}} = AST.find_nearest_do_block(@ast, node)
  end

  test "get_node_text_range" do
    # get the + expression
    node = AST.find_node(@ast, 3, 7)
    assert {:ok, {3, 5}, {3, 10}} = AST.get_node_text_range(node)

    node = AST.find_node(@ast, 4, 13)
    assert {:ok, {4, 5}, {4, 23}} = AST.get_node_text_range(node)

    IO.inspect(node, label: "node")
  end
end
