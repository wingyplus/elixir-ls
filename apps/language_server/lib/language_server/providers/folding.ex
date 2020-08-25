defmodule ElixirLS.LanguageServer.Providers.Folding do
  @moduledoc """
  A textDocument/foldingRange provider implementation.
  """

  @doc """
  Create a folding ranges from `source_file`.
  """
  def folding_ranges(source_file) do
    ranges =
      source_file.text
      |> Code.string_to_quoted!()
      |> IO.inspect()
      |> do_block_folding_range()

    {:ok, ranges}
  end

  defp do_block_folding_range({:defmodule, [line: line], [_module, doblock]}) do
    case doblock do
      [do: {:__block__, [], body}] ->
        # Currently, I didn't set startCharacter and endCharacter because vim-lsp request capabilities
        # with lineFoldingOnly: true. So we can ignore it for now.
        [
          %{
            "startLine" => line - 1,
            "endLine" => line + get_last_line(body) - 1
          }
        ]

      _ ->
        []
    end
  end

  defp do_block_folding_range(_), do: []

  defp get_last_line(statements) when is_list(statements),
    do: get_last_line(Enum.at(statements, -1))

  defp get_last_line({kw, [line: line], [_, block]}) when kw == :def or kw == :defp do
    case block do
      [do: {:__block__, _, block}] -> get_last_line(block) + 1
      [do: _v] -> line + 1
    end
  end

  defp get_last_line({:case, [line: line], [_, [do: block]]}) do
    case Enum.at(block, -1) do
      {:->, [line: line], _} -> line
      _ -> raise "This case should not reach"
    end
  end
end
