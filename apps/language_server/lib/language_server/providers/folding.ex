defmodule ElixirLS.LanguageServer.Providers.Folding do
  def folding_ranges(source_file) do
    ranges =
      source_file.text
      |> Code.string_to_quoted!(columns: true)
      |> folding_range_do_block()

    {:ok, ranges}
  end

  defp folding_range_do_block(_ast) do
    []
  end
end
