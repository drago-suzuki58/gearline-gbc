# ギアライン (GEARLINE)

ゲームボーイカラー専用の工場建設シミュレーション。RGBDS製（アセンブリ）。

## ビルド

    RGBDS=/path/to/rgbds/ ./build.sh    # rgbasm 等にPATHが通っていれば RGBDS は不要

`tools/gen.py` がタイル・フォント・文字列・BGM・パレットを `build/` に生成し、`gearline.gbc` を出力します。
カートリッジ種別は MBC5+RAM+BATTERY（ROM 32KB / SRAM 8KB）。

## 操作

| ボタン | 動作 |
|---|---|
| 十字キー | カーソル移動 |
| A | 建てる / 組立機のレシピ変更 / ベルトの向き変更（押したまま移動で連続設置） |
| B | こわす（材料は全額返却。押したまま移動で連続撤去） |
| SELECT | 向きを回転 |
| START | メニュー（建物選択・目標・在庫・セーブ・BGM・あそびかた） |

## 構成

- `src/main.asm` 本体
- `tools/gen.py` アセット生成（ドット絵・文字列・目標データ・BGMはここで定義）
- `tools/harness.py` PyBoyを使った動作確認用ハーネス
- `third_party/misaki/` 美咲フォント（8x8）のデータ。Arduino-misakiUTF16 より
