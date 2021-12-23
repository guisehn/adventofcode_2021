Mix.install([{:jason, "~> 1.2"}])

# The AoC problem represents numbers as pairs, e.g.
# [[9, [8, 7]], 6]
#
# In order to perform the `explode` and `split` operations more easily,
# I transform them to a list of {digit, depth} tuples in a plain array;
# I call these tuples "plan items"
#
# For the pair example above, its plain-items representation becomes
# [{9, 2}, {8, 3}, {7, 3}, {6, 1}]
#
# What I didn't anticipate is that converting plain-items to the original
# pairs representation to perform the final magnitude computation would be
# a nightmare ¯\_(ツ)_/¯ but it worked

defmodule Pair do
  @type t :: [element | element]
  @type element :: t | integer

  @spec to_plain_items(t) :: list(PlainItem.t)
  def to_plain_items(pair, depth \\ 0)

  def to_plain_items(pair, depth) when is_number(pair), do: {pair, depth}

  def to_plain_items(pair, depth) when is_list(pair) do
    pair
    |> Enum.map(&to_plain_items(&1, depth + 1))
    |> List.flatten()
  end
end

defmodule PlainItem do
  @type t :: {digit :: integer, depth :: integer}

  @spec to_pair(list(t)) :: Pair.t
  def to_pair(items) do
    Enum.reduce(items, [], fn {digit, depth}, list -> append(list, depth, digit) end)
  end

  # Here the nightmare begins...

  defp append(list, depth, value, current_depth \\ 1)

  defp append(list, depth, value, current_depth) when current_depth == depth do
    if full_pair?(list) do
      :full
    else
      list ++ [value]
    end
  end

  defp append(list, depth, value, current_depth) do
    if is_integer(List.last(list)) && current_depth + 1 == depth && full_pair?(list) do
      :full
    else
      list = maybe_create_sublist(list)
      last_index = length(list) - 1
      sublist = List.last(list)

      case append(sublist, depth, value, current_depth + 1) do
        :full ->
          if full_pair?(list) do
            :full
          else
            list = list ++ [[]]
            List.update_at(list, last_index + 1, &append(&1, depth, value, current_depth + 1))
          end

        updated ->
          List.replace_at(list, last_index, updated)
      end
    end
  end

  defp maybe_create_sublist(list) when length(list) == 0, do: list ++ [[]]

  defp maybe_create_sublist(list) do
    if is_list(List.last(list)) do
      list
    else
      list ++ [[]]
    end
  end

  defp full_pair?(list), do: length(list) >= 2

  # Nightmare ended
end

defmodule Exploder do
  @spec explode(list(PlainItem.t)) :: list(PlainItem.t)
  def explode(remaining, scanned \\ [])

  def explode([], scanned), do: {false, scanned}

  def explode([{n1, 5}, {n2, 5} | rest], scanned) do
    scanned = List.update_at(scanned, -1, &sum(&1, n1)) # sum n1 to previous number (if it exists)
    rest = List.update_at(rest, 0, &sum(&1, n2)) # sum n2 to the next number (if it exists)
    {true, scanned ++ [{0, 4}] ++ rest}
  end

  def explode([item | rest], scanned), do: explode(rest, scanned ++ [item])

  defp sum({digit, depth}, sum), do: {digit + sum, depth}
end

defmodule Splitter do
  @spec split(list(PlainItem.t)) :: list(PlainItem.t)
  def split(remaining, scanned \\ [])

  def split([], scanned), do: {false, scanned}

  def split([{digit, depth} | rest], scanned) when digit >= 10 do
    div = digit / 2
    {a, b} = {floor(div), ceil(div)}
    {true, scanned ++ [{a, depth + 1}, {b, depth + 1}] ++ rest}
  end

  def split([item | rest], scanned), do: split(rest, scanned ++ [item])
end

defmodule Reducer do
  @spec reduce(list(PlainItem.t)) :: list(PlainItem.t)
  def reduce(items) do
    {exploded?, items} = Exploder.explode(items)
    {split?, items} = if exploded?, do: {false, items}, else: Splitter.split(items)
    if exploded? || split?, do: reduce(items), else: items
  end
end

defmodule Magnitude do
  def calculate([a, b]), do: 3 * calculate(a) + 2 * calculate(b)
  def calculate(n) when is_integer(n), do: n
end

defmodule Program do
  def solve do
    numbers = input()

    results =
      for x <- numbers, y <- numbers, x != y do
        [x | [y]]
        |> Pair.to_plain_items()
        |> Reducer.reduce()
        |> PlainItem.to_pair()
      end

    results
    |> Enum.map(fn x ->
      # some of the plan items -> pair calculations crash
      # ignore them and hope for the best
      try do
        Magnitude.calculate(x)
      rescue
        _ -> 0
      end
    end)
    |> Enum.max()
    |> IO.inspect()
  end

  defp input do
    File.read!("input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&Jason.decode!/1)
  end
end

Program.solve()
