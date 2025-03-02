# How to mock

モックライブラリを作成済の場合に、モック関数を追加する手順を示す。

ここで指すモックとは、テストダブルの一般名としての意味であり、実装内容によってダミー、スタブ、スパイ、モック、フェイクなど詳細は決定される。 参考: [これで迷わないテストダブルの分類(ダミー、スタブ、スパイ、モック、フェイク)](https://qiita.com/marchin_1989/items/3abaf7d57c501bb2c5a6)

## ヘッダを作成

- モックライブラリのヘッダ [(サンプルファイル)](test/include/mock_sample.h) に、メソッド定義 (コンパイル時に google mock によって関数定義に変換される) を追加。
- 必要に応じ、呼び出し時の stdio 出力などをテストモジュールから制御するための変数定義を追加。

以下の `mock_samplelogger_enable_trace` は、 `WillByDefault` や `ON_CALL` に同様の記述を行うことでも実現可能なため、 google mock で C 言語のソースをテストするにあたっての必須条件ではない。 モックをインスタンス化せずともテスト結果として戻り値を確認することができるようになるため、本レポジトリでは必要性によらずパターンとして定義している。

```cpp
extern int mock_samplelogger_enable_trace;
MOCK_METHOD(int, samplelogger, (int, const char *));
```

## mock 関数を作成

- モックライブラリのクラスの実装に、デフォルトの呼び出しに対する処理内容を実装。
  デフォルトの呼び出しに対する処理内容は記載を省略したり各テストで定義することも可能だが、きちんと実装するほうが好ましい。
- モックライブラリフォルダに、関数本体 [(サンプルファイル)](test/libsrc/mocksample/mock_samplelogger.cc) を作成。

```cpp
ON_CALL(*this, samplelogger(_, _))
    .WillByDefault(Invoke([](Unused, const char *str)
                            { return strlen(str); })); // NOTE: Unused を使うと未使用パラメータの警告を避け、かつ、未使用である旨が明確になる
```
