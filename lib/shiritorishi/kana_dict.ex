defmodule Shiritorishi.KanaDict do
  alias Shiritorishi.KanaDict.Translator

  defdelegate to_hira(text), to: Translator

  defdelegate to_kata(text), to: Translator

  defdelegate valid_text?(text), to: Translator

  defdelegate strip_ignored(text), to: Translator
end
