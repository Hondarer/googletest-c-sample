# TODO

+ Makefile の TEST_SRCS にカレントディレクトリの存在しないファイルが指定されていると、自分自身へのシンボリックリンクを生成してしまう。
  ```
  ln -s testterget.c testterget.c
  make: stat: testterget.c: シンボリックリンクの階層が多すぎます
  lrwxrwxrwx 1 user user   12  6月 11 06:53 testterget.c -> testterget.c
  ```
