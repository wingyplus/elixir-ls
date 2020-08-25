defmodule ElixirLS.LanguageServer.Providers.Folding do
  @moduledoc """
  A textDocument/foldingRange provider implementation.

  The current implementation might not work with the function looks like:

    def hello(), do: :world

    def hello() do
      :world
    end

  Because 2 examples above produces the same AST result from
  Code.string_to_quoted/1.
  """

  @doc """
  Create a folding ranges from `source_file`.
  """
  def folding_ranges(source_file) do
    ranges =
      source_file.text
      |> Code.string_to_quoted!(line: 0)
      |> IO.inspect()
      |> do_block_folding_range()

    {:ok, ranges}
  end

  defp do_block_folding_range({:defmodule, [line: line], [_module, doblock]}) do
    case doblock do
      # capture block expression.
      [do: {:__block__, [], body}] ->
        # Currently, I didn't set startCharacter and endCharacter because vim-lsp request capabilities
        # with lineFoldingOnly: true. So we can ignore it for now.
        [
          %{
            "startLine" => line,
            "endLine" => line + get_last_line(body)
          }
        ]

      _ ->
        []
    end
  end

  defp do_block_folding_range(_), do: []

  defp get_last_line(exprs) when is_list(exprs),
    do: get_last_line(Enum.at(exprs, -1))

  # Extract last expression from :def or :defp.
  defp get_last_line({kw, [line: line], [_, block]}) when kw == :def or kw == :defp do
    case block do
      [do: {:__block__, _, block}] -> get_last_line(block) + 1
      # How could we determine between to 2 expressions:
      #
      #   def hello, do: :world
      #
      # And
      #
      #   def hello do
      #     :world
      #   end
      [do: _v] -> line
    end
  end

  defp get_last_line({:case, [line: line], [_, [do: block]]}) do
    last_line =
      case Enum.at(block, -1) do
        {:->, _, [_, expressions]} when is_list(expressions) ->
          get_last_line(Enum.at(expressions, -1))

        {:->, [line: line], [_, _]} ->
          line

        _ ->
          raise "This case should not reach"
      end

    # Plus 1 for end block
    last_line + 1
  end

  defp get_last_line({:raise, [line: line], _}), do: line
end
