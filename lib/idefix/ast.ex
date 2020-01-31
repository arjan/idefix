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

  @doc """
  Find the closest surrounding do: block given the AST and a target node.
  """
  def find_nearest_do_block(ast, node) do
    {:ok, stack} = collect_ast_stack(ast, &(&1 == node))

    stack
    |> Enum.reverse()
    |> Enum.find(&match?({:do, _}, &1))
  end

  @doc """
  Collect the AST stack; test each AST node against a predicate
  function. When the predicate matches the function, it will return
  the entire stack of the AST up to the matched node.
  """
  def collect_ast_stack({_, args} = node, predicate) do
    collect_ast_stack(args, predicate)
    |> opt_stack(node)
  end

  def collect_ast_stack(args, predicate) when is_list(args) do
    reduce_ast_stack_list(args, predicate)
  end

  def collect_ast_stack({x, _, args} = node, predicate)
      when is_atom(x) and is_list(args) do
    case predicate.(node) do
      true ->
        {:ok, []}

      false ->
        reduce_ast_stack_list(args, predicate)
    end
  end

  def collect_ast_stack(node, predicate) do
    case predicate.(node) do
      true ->
        {:ok, []}

      false ->
        nil
    end
  end

  defp reduce_ast_stack_list(args, predicate) do
    Enum.reduce(args, nil, fn
      _, {:ok, _} = r ->
        r

      sub, nil ->
        case collect_ast_stack(sub, predicate) do
          {:ok, s} ->
            {:ok, [sub | s]}

          nil ->
            nil
        end
    end)
  end

  defp opt_stack({:ok, stack}, node), do: {:ok, [node | stack]}
  defp opt_stack(nil, _), do: nil

  @doc """
  Given an AST node, return a pair of {line, column} tuples which are
  the textual span of the node.
  """
  def get_node_text_range({_, _, _} = node) do
    {lines, columns} =
      Macro.prewalk(node, [], fn
        {_, m, _} = node, acc ->
          all =
            [
              line_plus_column(m),
              line_plus_column(m, :end_of_expression),
              line_plus_column(m, :closing)
            ]
            |> Enum.reject(&is_nil/1)

          {node, all ++ acc}

        node, acc ->
          {node, acc}
      end)
      |> elem(1)
      |> Enum.unzip()

    {:ok, {Enum.min(lines), Enum.min(columns)}, {Enum.max(lines), Enum.max(columns)}}
  end

  def get_node_text_range(_node) do
    {:error, :no_node_metadata}
  end

  defp line_plus_column(m, key \\ nil)

  defp line_plus_column(m, nil) do
    {m[:line], m[:column]}
  end

  defp line_plus_column(m, key) do
    case m[key] do
      nil -> nil
      k -> {k[:line], k[:column]}
    end
  end
end
