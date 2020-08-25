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
      |> String.to_charlist()
      |> :elixir_tokenizer.tokenize(0, [])
      |> case do
        {:ok, tokens} ->
          tokens
          |> do_block_folding_range()

        {:error, _} ->
          []
      end

    {:ok, ranges}
  end

  # {:ok,
  #  [
  #    {:identifier, {0, 1, nil}, :defmodule},
  #    {:alias, {0, 11, nil}, :A},
  #    {:do, {0, 13, nil}},
  #    {:eol, {0, 15, 1}},
  #    {:at_op, {1, 3, nil}, :@},
  #    {:identifier, {1, 4, nil}, :moduledoc},
  #    {:bin_string, {1, 14, nil}, ["This is module A"]},
  #    {:eol, {1, 32, 2}},
  #    {:identifier, {3, 3, nil}, :def},
  #    {:paren_identifier, {3, 7, nil}, :hello},
  #    {:"(", {3, 12, nil}},
  #    {:")", {3, 13, nil}},
  #    {:do, {3, 15, nil}},
  #    {:eol, {3, 17, 1}},
  #    {:atom, {4, 5, nil}, :world},
  #    {:eol, {4, 11, 1}},
  #    {:end, {5, 3, nil}},
  #    {:eol, {5, 6, 1}},
  #    {:end, {6, 1, nil}},
  #    {:eol, {6, 4, 1}}
  #  ]}
  defp do_block_folding_range(tokens) when is_list(tokens) do
    tokens
    |> Enum.filter(&find_open_close_do_blocks/1)
    |> pairing_do_end_block()
    |> Enum.map(fn {{:do, {start_line, _, _}}, {:end, {end_line, _, _}}} ->
      %{"startLine" => start_line, "endLine" => end_line - 1}
    end)
  end

  defp find_open_close_do_blocks({:do, {line, column, _}} = token), do: true
  defp find_open_close_do_blocks({:end, {line, column, _}} = token), do: true
  defp find_open_close_do_blocks(_), do: false

  defp pairing_do_end_block([]), do: []

  # TODO: Fix crash in case no match parentheses.
  # TODO: Fix crash in case we have multiple defmodule in top-level file.
  defp pairing_do_end_block(tokens) do
    [open | tail] = tokens
    [close | tail] = Enum.reverse(tail)
    [{open, close}] ++ pairing_do_end_block(Enum.reverse(tail))
  end
end
