# スタックトレース取得サンプル

## 概要

このディレクトリには、C言語でスタックトレース（コールスタック）を取得するサンプルプログラムが含まれています。
最終的にはテストライブラリへ組み込むことを想定しています。

## ファイル

- `fixed_trace.c` - スタックトレース取得プログラム（Linux/Windows対応）

## ビルド方法

### Linux (gcc)

```bash
gcc -g -o fixed_trace fixed_trace.c -lbfd -ldl
```

**必要なライブラリ:**
- `libbfd-dev` (binutils-dev)
- デバッグ情報生成のため `-g` オプションが必須

**インストール例 (Ubuntu/Debian):**
```bash
sudo apt-get install binutils-dev
```

### Windows (MSVC)

```cmd
cl /Zi fixed_trace.c dbghelp.lib
```

**必要な設定:**
- `/Zi` オプションでデバッグ情報（PDB）を生成
- `dbghelp.lib` のリンクが必須
- Visual Studio または Windows SDKが必要

## 実行方法

```bash
./fixed_trace      # Linux
fixed_trace.exe    # Windows
```

## 出力例

```
Stack trace (most recent call first):
  File: fixed_trace.c, Line: 144, Function: func3
  File: fixed_trace.c, Line: 149, Function: func2
  File: fixed_trace.c, Line: 154, Function: func1
  File: fixed_trace.c, Line: 159, Function: main
```

## 実装の詳細

### Linux版
- **ライブラリ:** GNU BFD (Binary File Descriptor library)
- **API:**
  - `backtrace()` - スタックフレームのアドレスを取得
  - `bfd_*()` - デバッグシンボル情報の解析
- **特徴:**
  - ELFバイナリのシンボルテーブルを直接解析
  - `/proc/self/exe` から実行ファイルパスを取得

### Windows版
- **ライブラリ:** DbgHelp.dll
- **API:**
  - `CaptureStackBackTrace()` - スタックフレームのアドレスを取得
  - `SymInitialize()` - デバッグシンボルの初期化
  - `SymFromAddr()` - アドレスから関数名を取得
  - `SymGetLineFromAddr64()` - アドレスからファイル名・行番号を取得
- **特徴:**
  - PDB (Program Database) ファイルからデバッグ情報を読み込み
  - `SYMOPT_LOAD_LINES` オプションで行番号情報を有効化

## 注意事項

### 共通
1. **デバッグ情報が必須**
   - Linuxは `-g` オプション
   - Windowsは `/Zi` オプション
   - リリースビルド（最適化ビルド）では正確な情報が取得できない場合があります

2. **インライン展開の影響**
   - コンパイラ最適化でインライン展開された関数はスタックトレースに現れません
   - 正確なトレースが必要な場合は最適化を無効化してください

3. **シンボル情報のストリップ**
   - `strip` コマンドでシンボル情報を削除すると機能しません

### Linux固有
1. **libbfd のバージョン依存**
   - bfdライブラリのAPIはバージョンにより変更される場合があります
   - 古いバージョンでは `bfd_get_section_flags()` や `bfd_get_section_vma()` が非推奨の可能性があります

2. **セキュリティ制限**
   - 一部の環境では `/proc/self/exe` へのアクセスが制限される場合があります

3. **依存ライブラリ**
   - 配布時は libbfd の動的リンク依存に注意
   - 静的リンクも検討可能ですがライセンス（GPL）に注意

### Windows固有
1. **PDBファイルの配置**
   - デバッグ情報（PDB）は実行ファイルと同じディレクトリに配置してください
   - または環境変数 `_NT_SYMBOL_PATH` でシンボルパスを設定

2. **64bit/32bit**
   - `DWORD64`, `IMAGEHLP_LINE64` など、64bit版APIを使用しています
   - 32bit環境では適宜調整が必要な場合があります

3. **Windows XP以降**
   - `CaptureStackBackTrace()` はWindows XP SP1以降で使用可能
   - より詳細な情報が必要な場合は `StackWalk64()` の使用を検討

## テストライブラリへの組み込み時の考慮事項

1. **マルチスレッド対応**
   - 現在の実装はグローバル変数を使用しているため、スレッドセーフではありません
   - スレッドローカルストレージまたは排他制御の追加が必要です

2. **エラーハンドリング**
   - 現在は `exit(EXIT_FAILURE)` で終了していますが、ライブラリ化時は適切なエラー値の返却に変更

3. **メモリ管理**
   - Windows版では `calloc/free` を使用しています
   - カスタムアロケータとの統合を検討

4. **出力先のカスタマイズ**
   - 現在は `printf` で標準出力に出力
   - コールバック関数やバッファへの出力に変更を検討

## 参考資料

- [GNU BFD Documentation](https://sourceware.org/binutils/docs/bfd/)
- [DbgHelp API (Microsoft)](https://docs.microsoft.com/en-us/windows/win32/debug/dbghelp-functions)
- [backtrace(3) - Linux man page](https://linux.die.net/man/3/backtrace)
