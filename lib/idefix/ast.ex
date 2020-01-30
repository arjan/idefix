defmodule Idefix.AST do
  @doc """
  Parse Elixir code in a format for easy manipulation
  """
  def parse(input) do
    opts = [
      columns: true,
      token_metadata: true,
      warn_on_unnecessary_quotes: false
    ]

    Code.string_to_quoted(input, opts)
  end

  @doc """
  Given a line/column pair; find the nearest AST node.
  """
  def find_node(ast, line, col) do
    Macro.prewalk(ast, nil, fn
      {_, meta, _} = n, nil ->
        if meta[:line] == line do
          {n, {n, meta}}
        else
          {n, nil}
        end

      {_, newmeta, _} = n0, {n, oldmeta} ->
        if newmeta[:line] == line and abs(newmeta[:column] - col) <= abs(oldmeta[:column] - col) do
          {n0, {n0, newmeta}}
        else
          {n0, {n, oldmeta}}
        end

      n, acc ->
        {n, acc}
    end)
    |> elem(1)
    |> elem(0)
  end
end
