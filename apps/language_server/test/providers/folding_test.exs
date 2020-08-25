defmodule ElixirLS.LanguageServer.Providers.FoldingTest do
  use ExUnit.Case

  alias ElixirLS.LanguageServer.Providers.Folding

  test "folding 1 defmodule 1 moduledoc 1 function" do
    assert {:ok, ranges} =
             %{
               text: """
               defmodule A do
                 @moduledoc "This is module A"

                 def hello() do
                   :world
                 end
               end
               """
             }
             |> Folding.folding_ranges()

    assert ranges == [%{"endLine" => 5, "startLine" => 0}, %{"endLine" => 4, "startLine" => 3}]
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

    assert ranges == [
             %{"endLine" => 10, "startLine" => 0},
             %{"endLine" => 9, "startLine" => 3},
             %{"endLine" => 8, "startLine" => 6}
           ]

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

    assert ranges == [
             %{"endLine" => 9, "startLine" => 0},
             %{"endLine" => 8, "startLine" => 3},
             %{"endLine" => 7, "startLine" => 5}
           ]
  end

  # @tag :f
  # Test self source that can be folding all entire module. It's complex enough
  # use as a test cases. :)
  # test "folding.ex" do
    # f = File.read!("lib/language_server/providers/folding.ex")
    # lines = String.split(f, "\n") |> Enum.count()
# 
    # assert {:ok, ranges} = %{text: f} |> Folding.folding_ranges()
    # # 1 for zero-based line and 1 for before last end block.
    # assert ranges == [%{"endLine" => lines - 3, "startLine" => 0}]
  # end

  # test "multiple defmodule in the top-level of file" do
    # assert {:ok, ranges} =
             # %{
               # text: """
               # defmodule A do
                 # @moduledoc "This is module A"
                 # def hello() do
                   # a = 20
# 
                   # case a do
                     # 20 -> :ok
                     # _ -> :notok
                   # end
                 # end
               # end
# 
               # defmodule B do
                 # @moduledoc "This is module B"
                 # def hello() do
                   # a = 20
# 
                   # case a do
                     # 20 -> :ok
                     # _ -> :notok
                   # end
                 # end
               # end
               # """
             # }
             # |> Folding.folding_ranges()
# 
    # assert ranges == [%{"endLine" => 9, "startLine" => 0}, %{"endLine" => 33, "startLine" => 12}]
  end
end
