# googletest-c-sample

A knowledge pool on how to test existing C programs using googletest.

いわゆる「レガシーな C コード」を googletest でテスト可能にするための知見の蓄積です。

VSCode を快適に利用するためのノウハウについても含んでいます。

## 想定している利用方法

Linux 上の C コードを、VSCode から編集しデバッグを行う形態。

## フォルダ構成

- prod テスト対象 (前提として、製品コードを想定。このフォルダ以下は、テスト環境では触らない)
- test テストコード
    - cmnd テスト支援コマンド類
    - include テストコード用の include
    - include_override 製品コードをビルドする際に、注入したい差分 include
    - lib テストコードのアーカイブ
    - libsrc テストコードの共有ソース (mock はよほど固有でない限り、ここに定義)
    - src テストコードのソース

## ビルド

親階層で、`make all` (clean & make) または `make`

libsrc や src の各階層における部分ビルドも可能。

## テスト

親階層で、`make test`

src の各階層における部分テストも可能。

## ビルドとテスト

親階層で、`make all test` または `make clean test`

## テスト結果

各テストモジュールの階層に `results` フォルダが作られ、テストケースごとに結果とカバレッジが格納されます。

## 依存コンポーネント

- gcc
- g++
- make
- googletest (google mock)
- nkf
  ※ nkf は現在ではディストリビューションに同梱されないことが多いですが、ソースが EUC-JP かつ VSCode でエラーログを日本語表示するために使用しています。

## 任意コンポーネント

- gcovr
- lcov
