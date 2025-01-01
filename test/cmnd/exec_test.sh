#!/bin/bash

# テストバイナリのパス
TEST_BINARY=$(basename `pwd`)

# テスト一覧を取得
function list_tests() {
    ./$TEST_BINARY --gtest_list_tests | awk '
    /^[^ ]/ {suite=$1} 
    /^  / {print suite $1}'
}

# テストを実行 (個別カバレッジあり)
function run_test() {
    local test_name=$1
    echo "Running test: $test_name"
    make clean-cov > /dev/null
    mkdir -p test_results/$test_name
    local temp_file=$(mktemp)
    local temp_exit_code=$(mktemp)
    script -q -c "./$TEST_BINARY --gtest_filter=\"$test_name\"; echo \$? > $temp_exit_code" $temp_file
    local result=$(cat $temp_exit_code)
    rm -f $temp_exit_code
    cat $temp_file | sed -r 's/\x1b\[[0-9;]*m//g' > test_results/$test_name/test_results.log
    rm -f $temp_file
    make take-gcov > /dev/null
    cp -p gcov/*.gcov test_results/$test_name/.
    return $result
}

# メイン処理
function main() {
    rm -rf test_results
    mkdir test_results

    echo "Listing all tests..."
    tests=$(list_tests)
    echo "Found $(echo "$tests" | wc -l) tests."

    for test_name in $tests; do
        run_test "$test_name"
        # すべてのテストをやり切ったほうが使い勝手が良い
        # 失敗しない前提であれば、以下を活かしても良い
        #local result=$?
        #if [ "$result" -ne 0 ]; then
        #    return 1
        #fi
    done

    # すべてのテストを通しで実行後、全体カバレッジを取得
    # プロセスの依存性排除のため、一括ではなく個別にテストを実施
    SUCCESS_COUNT=0
    FAILURE_COUNT=0
    make clean-cov > /dev/null
    mkdir -p test_results/all_tests
    for test_name in $tests; do
        local temp_file=$(mktemp)
        local temp_exit_code=$(mktemp)
        script -q -c "./$TEST_BINARY --gtest_filter=\"$test_name\"; echo \$? > $temp_exit_code" $temp_file > /dev/null
        local result=$(cat $temp_exit_code)
        rm -f $temp_exit_code
        if [ $result -eq 0 ]; then
            echo -e "$test_name\tPASSED" >> test_results/all_tests/test_summary.log
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
            echo -e "$test_name\tFAILED" >> test_results/all_tests/test_summary.log
            FAILURE_COUNT=$((FAILURE_COUNT + 1))
        fi
        cat $temp_file | sed -r 's/\x1b\[[0-9;]*m//g' >> test_results/all_tests/test_results.log
        rm -f $temp_file
    done
    echo -e "----\nTotal tests\t$(echo "$tests" | wc -l)\nPassed\t$SUCCESS_COUNT\nFailed\t$FAILURE_COUNT" >> test_results/all_tests/test_summary.log
    make take-cov > /dev/null
    cp -p gcov/*.gcov test_results/all_tests/.
    cp -rp lcov test_results/all_tests/.

    make clean-cov > /dev/null

    return 0
}

# 実行
main
