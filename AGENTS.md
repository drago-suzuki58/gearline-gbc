# 開発メモ（エージェント向け）

## 方針

- ゲーム本体は Claude Fable 5.2 がワンショットで生成したもので、その記録として公開している。ゲームの仕様と内容（生成されるROM）は変更しない。
- 仕様の食い違いや不具合を見つけても、コードは修正せず `docs/spec.md` の「既知の挙動」に記録する。
- ビルド手順や周辺ファイルを変更した後は、ROMが変わっていないことを確認する。生成時のROMのSHA-1は `8746249d584b13e77c5ea782d752f549420e8e24`。

## ビルド

- `./build.sh` で `gearline.gbc` を生成する。RGBDSは v1.0.4 を前提とし、CIでも同じバージョンを `.github/workflows/build.yml` で固定している。バージョンを上げるときはワークフローのバージョンとSHA-256を更新し、生成ROMの差分を確認する。
- `tools/gen.py` は標準ライブラリだけで動かす。ビルドに追加のPythonパッケージを要求しない。
- 美咲フォントのデータはリポジトリに同梱しない。`tools/gen.py` が固定コミットのURLから `build/` に取得し、SHA-256で検証する。取得元を変えるときはURLとハッシュを両方更新する。
- `gearline.gbc` と `build/` はコミットしない。ROMはタグ（`v*`）のpushでGitHub Releasesに配布される。

## ソース構成と制約

- ゲーム本体は `src/main.asm` の1ファイル。`build/` 以下の生成物を `INCLUDE`/`INCBIN` する。
- ドット絵、文字列、目標データ、BGM、パレットは `tools/gen.py` で定義する。文字列は1行20文字以内（`gen.py` が検査する）、使える文字はフォントに含まれる文字に限られる。
- GBC専用（rgbfix `-C`）。MBC5+RAM+BATTERY、ROM 32KB、SRAM 8KB。

## 動作確認

- `uv sync` で開発用依存（PyBoy、Pillow）を入れ、`tools/harness.py` の `Game` クラスでROMを操作する。スクリーンショットは `build/shots/` に保存される。
- ハーネスはROMと `build/gearline.sym` を使うので、先に `./build.sh` を実行する。
