defmodule Shiritorishi.KanaDict.Table do

  def hira2kata do
    %{
      "あ" => "ア",
      "い" => "イ",
      "う" => "ウ",
      "え" => "エ",
      "お" => "オ",
      "か" => "カ",
      "き" => "キ",
      "く" => "ク",
      "け" => "ケ",
      "こ" => "コ",
      "さ" => "サ",
      "し" => "シ",
      "す" => "ス",
      "せ" => "セ",
      "そ" => "ソ",
      "た" => "タ",
      "ち" => "チ",
      "つ" => "ツ",
      "て" => "テ",
      "と" => "ト",
      "な" => "ナ",
      "に" => "ニ",
      "ぬ" => "ヌ",
      "ね" => "ネ",
      "の" => "ノ",
      "は" => "ハ",
      "ひ" => "ヒ",
      "ふ" => "フ",
      "へ" => "ヘ",
      "ほ" => "ホ",
      "ま" => "マ",
      "み" => "ミ",
      "む" => "ム",
      "め" => "メ",
      "も" => "モ",
      "や" => "ヤ",
      "ゐ" => "ヰ",
      "ゆ" => "ユ",
      "ゑ" => "ヱ",
      "よ" => "ヨ",
      "ら" => "ラ",
      "り" => "リ",
      "る" => "ル",
      "れ" => "レ",
      "ろ" => "ロ",
      "わ" => "ワ",
      "を" => "ヲ",
      "ん" => "ン",
      "が" => "ガ",
      "ぎ" => "ギ",
      "ぐ" => "グ",
      "げ" => "ゲ",
      "ご" => "ゴ",
      "ざ" => "ザ",
      "じ" => "ジ",
      "ず" => "ズ",
      "ぜ" => "ゼ",
      "ぞ" => "ゾ",
      "だ" => "ダ",
      "ぢ" => "ヂ",
      "づ" => "ヅ",
      "で" => "デ",
      "ど" => "ド",
      "ば" => "バ",
      "び" => "ビ",
      "ぶ" => "ブ",
      "べ" => "ベ",
      "ぼ" => "ボ",
      "ぱ" => "パ",
      "ぴ" => "ピ",
      "ぷ" => "プ",
      "ぺ" => "ペ",
      "ぽ" => "ポ",
      "ぁ" => "ァ",
      "ぃ" => "ィ",
      "ぅ" => "ゥ",
      "ぇ" => "ェ",
      "ぉ" => "ォ",
      "ヵ" => "ヵ",
      "っ" => "ッ",
      "ゃ" => "ャ",
      "ゅ" => "ュ",
      "ょ" => "ョ",
      "ー" => "ー"
    }
  end

  def kata2hira do
    %{
      "ア" => "あ",
      "イ" => "い",
      "ウ" => "う",
      "エ" => "え",
      "オ" => "お",
      "カ" => "か",
      "キ" => "き",
      "ク" => "く",
      "ケ" => "け",
      "コ" => "こ",
      "サ" => "さ",
      "シ" => "し",
      "ス" => "す",
      "セ" => "せ",
      "ソ" => "そ",
      "タ" => "た",
      "チ" => "ち",
      "ツ" => "つ",
      "テ" => "て",
      "ト" => "と",
      "ナ" => "な",
      "ニ" => "に",
      "ヌ" => "ぬ",
      "ネ" => "ね",
      "ノ" => "の",
      "ハ" => "は",
      "ヒ" => "ひ",
      "フ" => "ふ",
      "ヘ" => "へ",
      "ホ" => "ほ",
      "マ" => "ま",
      "ミ" => "み",
      "ム" => "む",
      "メ" => "め",
      "モ" => "も",
      "ヤ" => "や",
      "ヰ" => "ゐ",
      "ユ" => "ゆ",
      "ヱ" => "ゑ",
      "ヨ" => "よ",
      "ラ" => "ら",
      "リ" => "り",
      "ル" => "る",
      "レ" => "れ",
      "ロ" => "ろ",
      "ワ" => "わ",
      "ヲ" => "を",
      "ン" => "ん",
      "ガ" => "が",
      "ギ" => "ぎ",
      "グ" => "ぐ",
      "ゲ" => "げ",
      "ゴ" => "ご",
      "ザ" => "ざ",
      "ジ" => "じ",
      "ズ" => "ず",
      "ゼ" => "ぜ",
      "ゾ" => "ぞ",
      "ダ" => "だ",
      "ヂ" => "ぢ",
      "ヅ" => "づ",
      "デ" => "で",
      "ド" => "ど",
      "バ" => "ば",
      "ビ" => "び",
      "ブ" => "ぶ",
      "ベ" => "べ",
      "ボ" => "ぼ",
      "パ" => "ぱ",
      "ピ" => "ぴ",
      "プ" => "ぷ",
      "ペ" => "ぺ",
      "ポ" => "ぽ",
      "ァ" => "ぁ",
      "ィ" => "ぃ",
      "ゥ" => "ぅ",
      "ェ" => "ぇ",
      "ォ" => "ぉ",
      "ヵ" => "ヵ",
      "ッ" => "っ",
      "ャ" => "ゃ",
      "ュ" => "ゅ",
      "ョ" => "ょ",
      "ー" => "ー"
    }
  end

  def to_upper do
    %{
      "ぁ" => "あ",
      "ぃ" => "い",
      "ぅ" => "う",
      "ぇ" => "え",
      "ぉ" => "お",
      "ヵ" => "か",
      "っ" => "つ",
      "ゃ" => "や",
      "ゅ" => "ゆ",
      "ょ" => "よ",
      "ァ" => "ア",
      "ィ" => "イ",
      "ゥ" => "ウ",
      "ェ" => "エ",
      "ォ" => "オ",
      "ッ" => "ツ",
      "ャ" => "ヤ",
      "ュ" => "ユ",
      "ョ" => "ヨ"
    }
  end

  def ignore_set do
    MapSet.new([
      "ー"
    ])
  end
end
