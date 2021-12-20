defmodule Util do
  def parse_hex(value), do: parse_number(value, 16)

  def parse_bin(value), do: parse_number(value, 2)

  defp parse_number(list, base) when is_list(list), do:
    list |> Enum.join("") |> parse_number(base)

  defp parse_number(string, base) when is_binary(string), do:
    Integer.parse(string, base) |> elem(0)
end

defprotocol Packet.VersionSum do
  @spec sum(t) :: Packet.version
  def sum(packet)
end

defmodule Packet do
  import Util, only: [parse_bin: 1]

  @type t :: Packet.Literal.t() | Packet.Operator.t()

  @type bit :: 0 | 1
  @type id :: non_neg_integer
  @type version :: non_neg_integer

  @spec parse(list(bit)) :: Packet.t()
  def parse(bits) do
    {version, id, content} = parse_header(bits)

    case id do
      4 -> Packet.Literal.parse(version, content)
      _ -> Packet.Operator.parse(version, content)
    end
  end

  @spec parse_header(list(bit)) :: {version, id, list(bit)}
  defp parse_header(packet) do
    {version, packet} = Enum.split(packet, 3)
    {id, packet} = Enum.split(packet, 3)
    {parse_bin(version), parse_bin(id), packet}
  end
end

defmodule Packet.Literal do
  import Util, only: [parse_bin: 1]

  defstruct [:version, :value]

  @type t :: %Packet.Literal{version: Packet.version, value: integer}

  @spec parse(integer, list(Packet.bit)) :: {t, list(Packet.bit)}
  def parse(version, content) do
    {value, bits_left} = parse_value(content)
    {%Packet.Literal{version: version, value: parse_bin(value)}, bits_left}
  end

  @spec parse_value(list(Packet.bit), list(Packet.bit)) :: list(Packet.bit)
  defp parse_value(bits_left, acc \\ []) do
    {[continue | value], bits_left} = Enum.split(bits_left, 5)
    acc = acc ++ value

    case continue do
      1 -> parse_value(bits_left, acc)
      0 -> {acc, bits_left}
    end
  end

  defimpl Packet.VersionSum do
    def sum(packet), do: packet.version
  end
end

defmodule Packet.Operator do
  import Util, only: [parse_bin: 1]

  defstruct [:version, :subpackets]

  @type t :: %Packet.Operator{version: Packet.version, subpackets: list(Packet.t())}

  @spec parse(integer, list(Packet.bit)) :: {t, list(Packet.bit)}
  def parse(version, [length_type | content]) do
    {subpackets, bits_left} =
      case length_type do
        0 -> parse_with_length(content)
        1 -> parse_with_amount_of_subpackets(content)
      end

    {%Packet.Operator{version: version, subpackets: subpackets}, bits_left}
  end

  @spec parse_with_length(list(Packet.bit)) :: {t, list(Packet.bit)}
  defp parse_with_length(content) do
    {length, content} = Enum.split(content, 15)
    length = parse_bin(length)
    {subpackets_bits, outer_rest} = Enum.split(content, length)
    {subpackets, inner_rest} = parse_packets(subpackets_bits)
    {subpackets, inner_rest ++ outer_rest}
  end

  @spec parse_with_amount_of_subpackets(list(Packet.bit)) :: {t, list(Packet.bit)}
  defp parse_with_amount_of_subpackets(content) do
    {amount_of_subpackets, content} = Enum.split(content, 11)
    amount_of_subpackets = parse_bin(amount_of_subpackets)
    parse_packets(content, amount_of_subpackets)
  end

  @spec parse_packets(list(Packet.bit), integer | nil, list(Packet.t())) :: {t, list(Packet.bit)}
  defp parse_packets(content, limit \\ nil, packets_found \\ [])

  defp parse_packets([], _, packets_found), do: {Enum.reverse(packets_found), []}

  defp parse_packets(bits_left, 0, packets_found), do: {Enum.reverse(packets_found), bits_left}

  defp parse_packets(content, limit, packets_found) do
    {packet, bits_left} = Packet.parse(content)
    next_limit = if limit, do: limit - 1, else: nil
    parse_packets(bits_left, next_limit, [packet | packets_found])
  end

  defimpl Packet.VersionSum do
    def sum(%{subpackets: subpackets, version: version}) do
      subversions = subpackets |> Enum.map(&Packet.VersionSum.sum/1) |> Enum.sum()
      version + subversions
    end
  end
end

defmodule Program do
  import Util, only: [parse_hex: 1]

  def solve do
    input()
    |> Packet.parse()
    |> elem(0)
    |> Packet.VersionSum.sum()
    |> IO.inspect()
  end

  @spec input() :: list(Packet.bit)
  defp input do
    File.read!("input.txt")
    |> String.trim()
    |> parse_hex()
    |> Integer.to_string(2)
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> pad_bin(4)
  end

  defp pad_bin(bin, multiple) when rem(length(bin), multiple) == 0, do: bin
  defp pad_bin(bin, _multiple), do: [0 | bin]
end

Program.solve()
