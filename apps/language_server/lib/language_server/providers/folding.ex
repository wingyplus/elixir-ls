defmodule ElixirLS.LanguageServer.Providers.Folding do
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
        [
          %{
            "startLine" => line - 1,
            "endLine" => line - 1 + counting_line(body)
          }
        ]

      _ ->
        []
    end
  end

  defp do_block_folding_range(_), do: []

  defp counting_line(statements) do
    {:def, [line: line], [_, body]} =
      statements
      |> Enum.reverse()
      |> hd()

    line + Enum.count(body)
  end
end
