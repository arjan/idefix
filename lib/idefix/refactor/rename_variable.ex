defmodule Idefix.Refactor.RenameVariable do
  @moduledoc """
  Rename a variable at the point
  """

  alias Idefix.AST

  def rename_variable(input, {line, col}, newname) do
    ast = AST.parse(input)

    with {var, _meta, nil} <- Idefix.AST.find_node(ast, line, col) do
      IO.puts("Rename #{var} to #{newname}")

      input
    else
      _ -> {:error, "Not a variable"}
    end
  end
end
