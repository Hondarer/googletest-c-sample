#!/usr/bin/awk -f

# 使用方法: awk -v test_name="test_samplelogger.normal_call" -f get_test_code.awk test_file.cc

BEGIN {
    extracting = 0;              # テストケースの抽出中フラグ
    brace_count = 0;             # 波括弧のカウント
    buffer = "";                 # コメント用バッファ
    in_multiline_comment = 0;    # 複数行コメント中フラグ
    test_found = 0;              # テストケースを見つけたフラグ

    # test_nameをクラス名とテスト名に分割
    split(test_name, parts, "\\.");
    if (length(parts) != 2) {
        print "Error: Invalid test_name format. Use ClassName.TestName" > "/dev/stderr";
        exit 1;
    }
    class_name = parts[1];
    test_case_name = parts[2];
}

# 複数行コメントの開始と終了が同じ行にある場合
/\/\*.*\*\// {
    if (!extracting) {
        buffer = buffer $0 "\n";
        next;
    }
}

# 複数行コメントの開始
/\/\*/ {
    if (!extracting) {
        in_multiline_comment = 1;
        buffer = buffer $0 "\n";
        next;
    }
}

# 複数行コメントの終了
/\*\// {
    if (!extracting) {
        in_multiline_comment = 0;
        buffer = buffer $0 "\n";
        next;
    }
}

# 複数行コメント中はバッファに追加
in_multiline_comment {
    if (!extracting) {
        buffer = buffer $0 "\n";
        next;
    }
}

# 行コメントをバッファに追加
/^[[:space:]]*\/\// {
    if (!extracting) {
        buffer = buffer $0 "\n";
        next;
    }
}

# 空行でバッファをクリア（複数行コメント中を除く）
/^[[:space:]]*$/ {
    if (!extracting && !in_multiline_comment && buffer != "") {
        buffer = "";  # バッファをクリア
        next;
    }
}

# } を見つけたらバッファをクリア
/^[[:space:]]*}[[:space:]]*$/ {
    if (!extracting) {
        buffer = "";
        next;
    }
}

# TEST, TEST_F, TEST_P の形式にマッチするテストの開始地点を判定
{
    # 動的な正規表現を構築
    test_pattern = "^[[:space:]]*TEST(_[FP]*)?\\([[:space:]]*" class_name "[[:space:]]*,[[:space:]]*" test_case_name "[[:space:]]*\\)";

    if ($0 ~ test_pattern) {
        extracting = 1;
        test_found = 1;

        # コメントがある場合は出力
        if (buffer != "") {
            printf "%s", buffer;
        }
        buffer = "";  # バッファをクリア

        print $0;
        brace_count = 0;  # 新しいブロックのためカウントをリセット
        next;
    }
}

# テストケースの中身を出力（TEST系ブロック内のみ）
extracting {
    print $0;

    # { の数を増加
    brace_count += gsub(/\{/, "{");

    # } の数を減少
    brace_count -= gsub(/\}/, "}");

    # ブロック終了を検知
    if (brace_count == 0) {
        extracting = 0;
        exit 0;  # スクリプト終了
    }
}

# 他のコードブロックは無視
!extracting {
    next;
}

# ENDブロックでテストケースが見つからなかった場合の処理
END {
    if (!test_found) {
        print "Error: Test case \"" test_name "\" not found." > "/dev/stderr";
        exit 1;  # 異常終了
    }
}
