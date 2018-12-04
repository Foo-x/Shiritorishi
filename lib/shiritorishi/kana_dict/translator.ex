defmodule Shiritorishi.KanaDict.Translator do
  alias Shiritorishi.KanaDict.Table

  def to_hira(text) do
    fun = fn char ->
      if Map.has_key?(Table.hira2kata(), char) do
        char
      else
        Table.kata2hira()[char]
      end
    end
    translate(text, fun)
  end

  def to_kata(text) do
    fun = fn char ->
      if Map.has_key?(Table.kata2hira(), char) do
        char
      else
        Table.hira2kata()[char]
      end
    end
    translate(text, fun)
  end

  def to_upper(text) do
    fun = fn char ->
      if Map.has_key?(Table.to_upper(), char) do
        Table.to_upper()[char]
      else
        char
      end
    end
    translate(text, fun)
  end

  def valid_text?(text) do
    text
      |> String.graphemes
      |> Enum.all?(&(Map.has_key?(Table.hira2kata(), &1) or Map.has_key?(Table.kata2hira(), &1)))
  end

  def strip_ignored(text) do
    ignore_chars = Enum.join Table.ignore_set()
    String.replace(text, ~r/[#{ignore_chars}]/u, "")
  end

  defp translate(text, fun) do
    text
      |> String.graphemes
      |> Enum.map(&(fun.(&1)))
      |> Enum.reject(&is_nil/1)
      |> Enum.join
  end
end
