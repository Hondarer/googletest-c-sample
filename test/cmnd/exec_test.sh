#!/bin/bash

# このスクリプトのパス
SCRIPT_DIR=$(dirname "$0")

# ワークスペースのディレクトリ
WORKSPACE_FOLDER=$SCRIPT_DIR/../../

# ソースファイルのエンコード指定から LANG を得る
FILES_LANG=$(sh $SCRIPT_DIR/get_files_lang.sh $WORKSPACE_FOLDER)

# テストバイナリのパス
TEST_BINARY=$(basename `pwd`)

# テスト一覧を取得
function list_tests() {
    ./$TEST_BINARY --gtest_list_tests | awk '
    /^[^ ]/ {suite=$1} 
    /^  / {print suite substr($0, 3)}'
}

# テストを実行 (個別カバレッジあり)
function run_test() {
    local test_comment=""
    if [[ "$1" == *#* ]]; then
        test_comment=" #${1#*#}"
    fi
    local test_name=$(echo "$1" | cut -d' ' -f1)
    make clean-cov > /dev/null
    mkdir -p results/$test_name
    local temp_file=$(mktemp)
    local temp_exit_code=$(mktemp)

    # テストコードに着色する場合:
    # cat *.cc | awk -v test_name=\"$test_name\" -f $SCRIPT_DIR/get_test_code.awk | source-highlight -s cpp -f esc;
    LANG=$FILES_LANG script -q -c "echo -e \"\nRunning test: $test_name$test_comment\"; \
        echo \"----\"; \
        cat *.cc | awk -v test_id=\"$test_name\" -f $SCRIPT_DIR/get_test_code.awk; \
        echo \"----\"; \
        ./$TEST_BINARY --gtest_filter=\"$test_name\"; \
        echo \$? > $temp_exit_code" $temp_file

    local result=$(cat $temp_exit_code)
    rm -f $temp_exit_code
    cat $temp_file | sed -r 's/\x1b\[[0-9;]*m//g' > results/$test_name/results.log
    rm -f $temp_file
    make take-gcov > /dev/null

    if ls gcov/*.gcov 1> /dev/null 2>&1; then
        for file in gcov/*.gcov; do
            cp -p "$file" "results/$test_name/$(basename "$file").txt"
        done
    fi

    return $result
}

# メイン処理
function main() {
    rm -rf results
    mkdir results

    echo "Listing all tests..."
    tests=$(list_tests)
    tests=$(echo "$tests" | sort)
    echo "Found $(echo "$tests" | wc -l) tests."

    IFS=$'\n'
        for test_name_w_comment in $tests; do
            run_test "$test_name_w_comment"
            # すべてのテストをやり切ったほうが使い勝手が良い
            # 失敗しない前提であれば、以下を活かしても良い
            #local result=$?
            #if [ "$result" -ne 0 ]; then
            #    return 1
            #fi
        done
    unset IFS

    # すべてのテストを通しで実行後、全体カバレッジを取得
    # プロセスの依存性排除のため、一括ではなく個別にテストを実施
    SUCCESS_COUNT=0
    FAILURE_COUNT=0
    make clean-cov > /dev/null
    mkdir -p results/all_tests

    IFS=$'\n'
        for test_name_w_comment in $tests; do
            local temp_file=$(mktemp)
            local temp_exit_code=$(mktemp)
            local test_comment=""
            if [[ "$test_name_w_comment" == *#* ]]; then
                test_comment=" #${test_name_w_comment#*#}"
            fi
            local test_name=$(echo "$test_name_w_comment" | cut -d' ' -f1)

            LANG=$FILES_LANG script -q -c "echo -e \"\nRunning test: $test_name$test_comment\"; \
                echo \"----\"; \
                cat *.cc | awk -v test_id=\"$test_name\" -f $SCRIPT_DIR/get_test_code.awk; \
                echo \"----\"; \
                ./$TEST_BINARY --gtest_filter=\"$test_name\"; \
                echo \$? > $temp_exit_code" $temp_file > /dev/null

            local result=$(cat $temp_exit_code)
            rm -f $temp_exit_code
            if [ $result -eq 0 ]; then
                echo -e "$test_name\tPASSED" >> results/all_tests/summary.log
                SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            else
                echo -e "$test_name\tFAILED" >> results/all_tests/summary.log
                FAILURE_COUNT=$((FAILURE_COUNT + 1))
            fi
            cat $temp_file | sed -r 's/\x1b\[[0-9;]*m//g' >> results/all_tests/results.log
            rm -f $temp_file
        done
    unset IFS

    echo -e "----\nTotal tests\t$(echo "$tests" | wc -l)\nPassed\t$SUCCESS_COUNT\nFailed\t$FAILURE_COUNT" >> results/all_tests/summary.log
    make take-cov > /dev/null

    if ls gcov/*.gcov 1> /dev/null 2>&1; then
        for file in gcov/*.gcov; do
            cp -p "$file" "results/all_tests/$(basename "$file").txt"
        done
    fi

    if ls lcov/* 1> /dev/null 2>&1; then
        cp -rp lcov results/all_tests/.

        # FILES_LANG が utf-8 でない場合の処理
        if [[ ! "${FILES_LANG}" =~ [Uu][Tt][Ff][-+_]*8 ]]; then
            find results/all_tests/lcov -name "*.gcov.html" | while read -r file; do
                sed -i "s/charset=UTF-8/charset=${FILES_LANG#*.}/" "$file"
            done
        fi
    fi

    echo -e ""
    cat results/all_tests/summary.log

    if [ $FAILURE_COUNT -eq 0 ]; then
        echo -e "\e[32m"
            sh $SCRIPT_DIR/banner.sh PASSED
        echo -e "\e[0m"
    else
        echo -e "\e[31m"
            sh $SCRIPT_DIR/banner.sh FAILED
        echo -e "\e[0m"
        return 1
    fi

    return 0
}

# 実行
main
