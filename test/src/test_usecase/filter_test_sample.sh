#!/bin/bash

# make に GTEST_FILTER を指定すると、テストを選択的に実行できる
#   テストクラス名.テスト名 または
#   テストパラメータプレフィックス/テストクラス名.テスト名/テストパラメータ名 により指定する
# フレームワークでの表示上は、パラメータテストの ID を並び変えているので指定内容に注意
#   (テストクラス名.テスト名/テストパラメータプレフィックス/テストパラメータ名 にしている)
make test GTEST_FILTER=MultiplicationTests2/MockClass5Test.MultiplyTest/test3_*

# 環境変数を export しても同様の動作になる
# 例:
#   export GTEST_FILTER=MultiplicationTests2/MockClass5Test.MultiplyTest/test3_*
#   unset GTEST_FILTER
