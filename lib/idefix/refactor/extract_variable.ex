defmodule Idefix.Refactor.ExtractVariable do
  @moduledoc """
  Extract the current expression into a variable
  """

  alias Idefix.AST

  def extract_variable(input, {line, col}, newname) do
    ast = AST.parse(input)

    node = AST.find_node(ast, line, col)
    block = AST.find_nearest_do_block(ast, node)
  end
end
