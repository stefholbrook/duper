# The results server wraps an Elixir map. When it starts, it sets its state to an empty map. The keys of this map are
# hash values, and the values are the list of one of more paths whose files have that hash.
# The server provides two API calls: one to add a hash/path pair to the map, the second to retrieve entries that have
# more than one path in the value (as these are two duplicate files).
defmodule Duper.Results do
  use GenServer

  @me __MODULE__

  # API

  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args, name: @me)
  end

  def add_hash_for(path, hash) do
    GenServer.cast(@me, {:add, path, hash})
  end

  def find_duplicates() do
    GenServer.call(@me, :find_duplicates)
  end

  # Server
  def init(:no_args) do
    {:ok, %{}}
  end

  def handle_cast({:add, path, hash}, results) do
    results =
      Map.update(
        # look in this map
        results,
        # for and entry with this key
        hash,
        # if not found, store this value
        [path],
        # else update with results of this function
        fn existing ->
          [path | existing]
        end
      )

    {:noreply, results}
  end

  def handle_call(:find_duplicates, _from, results) do
    {
      :reply,
      hashes_with_more_than_one_path(results),
      results
    }
  end

  defp hashes_with_more_than_one_path(results) do
    results
    |> Enum.filter(fn {_hash, paths} -> length(paths) > 1 end)
    |> Enum.map(&elem(&1, 1))
  end
end
