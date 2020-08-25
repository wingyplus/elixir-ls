defmodule ElixirLS.LanguageServer.Providers.FoldingTest do
  use ExUnit.Case

  alias ElixirLS.LanguageServer.Providers.Folding

  test "folding 1 defmodule 1 moduledoc 1 function" do
    assert {:ok, ranges} =
             %{
               text: """
               defmodule A do # L1
                 @moduledoc "This is module A"

                 def hello() do # L4
                   :world
                 end
               end # L7
               """
             }
             |> Folding.folding_ranges()

    assert ranges == [%{"endLine" => 5, "startLine" => 0}]
  end

  test "folding complex function" do
    assert {:ok, ranges} =
             %{
               text: """
               defmodule B do
                 @moduledoc "This is module A"

                 def hello() do
                   a = 20

                   case a do
                     20 -> :ok
                     _ -> :notok
                   end
                 end
               end
               """
             }
             |> Folding.folding_ranges()

    assert ranges == [%{"endLine" => 10, "startLine" => 0}]

    assert {:ok, ranges} =
             %{
               text: """
               defmodule B do
                 @moduledoc "This is module A"

                 def hello() do
                   a = 20
                   case a do
                     20 -> :ok
                     _ -> :notok
                   end
                 end
               end
               """
             }
             |> Folding.folding_ranges()

    assert ranges == [%{"endLine" => 9, "startLine" => 0}]
  end
end
