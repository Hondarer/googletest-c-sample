#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include <test_com.h>
#include <mock_stdio.h>

#include <sampleinc.h>

using namespace testing;

class test_samplelogger : public Test
{
    void SetUp() override
    {
        clearTraceLevel();
        setTraceLevel("mock_fclose", TRACE_DETAIL);
        setTraceLevel("mock_fflush", TRACE_DETAIL);
        setTraceLevel("mock_fopen", TRACE_DETAIL);
        setTraceLevel("mock_fprintf", TRACE_DETAIL);
        setTraceLevel("mock_vfprintf", TRACE_DETAIL);
    }
};

TEST_F(test_samplelogger, normal_call)
{
    // Arrange
    NiceMock<Mock_stdio> mock_stdio;    // 宣言のないデフォルト Mock への呼び出し警告をしない
    mock_stdio.switch_to_mock_fileio(); // ファイルアクセスに関する関数をすべてモックに差し替える

    // Pre-Assert

    // Act
    int rtc = samplelogger(LOG_INFO, "%s\n", "normal_call");

    // Assert
    EXPECT_EQ(12, rtc);
}

TEST_F(test_samplelogger, fopen_failed)
{
    // Arrange
    Mock_stdio mock_stdio;
    mock_stdio.switch_to_mock_fileio(); // ファイルアクセスに関する関数をすべてモックに差し替える

    // Pre-Assert
    EXPECT_CALL(mock_stdio, fopen(_, _, _, _, _))
        .WillOnce(InvokeWithoutArgs([]()
                                    { errno=EIO; return nullptr; })); // 5: I/O error

    // Act
    int rtc = samplelogger(LOG_INFO, "%s\n", "fopen_failed");

    // Assert
    EXPECT_EQ(-1, rtc);
}

TEST_F(test_samplelogger, fclose_failed_completely_expect_call)
{
    /*
    Mock の各メソッドは必ず検証するか、NiceMock を使用すること。
    NiceMock<Mock_stdio> でない場合、以下の警告が出力される。

    Uninteresting mock function call - taking default action specified at:
    mock_stdio.cc:20:
        Function call: fopen(0x47ef52 pointing to "/tmp/sample.log", 0x47ef50 pointing to "a")
            Returns: 0x3043dea0

    Uninteresting mock function call - taking default action specified at:
    mock_stdio.cc:23:
        Function call: fprintf(0x3043dea0, 0x3043da80 pointing to "[2] ")
            Returns: 4
    */

    // Arrange
    Mock_stdio mock_stdio;
    mock_stdio.switch_to_mock_fileio(); // ファイルアクセスに関する関数をすべてモックに差し替える

#if 1
    // Pre-Assert
    EXPECT_CALL(mock_stdio, fopen(_, _, _, StrEq("/tmp/sample.log"), StrEq("a")))
        .Times(1);

    EXPECT_CALL(mock_stdio, fprintf(_, _, _, _, _))
        .Times(1);

    EXPECT_CALL(mock_stdio, vfprintf(_, _, _, _, _))
        .Times(1);
#else
    // Pre-Assert
#endif
    EXPECT_CALL(mock_stdio, fclose(_, _, _, _))
        .WillOnce(InvokeWithoutArgs([]()
                                    { errno=EIO; return EOF; })); // 5: I/O error

    // Act
    int rtc = samplelogger(LOG_INFO, "%s\n", "fclose_failed");

    // Assert
    EXPECT_EQ(-1, rtc);
}

TEST_F(test_samplelogger, fclose_failed_with_nicemock)
{
    /*
    Mock の各メソッドは必ず検証するか、NiceMock を使用すること。
    NiceMock<Mock_stdio> でない場合、以下の警告が出力される。

    Uninteresting mock function call - taking default action specified at:
    mock_stdio.cc:20:
        Function call: fopen(0x47ef52 pointing to "/tmp/sample.log", 0x47ef50 pointing to "a")
            Returns: 0x3043dea0

    Uninteresting mock function call - taking default action specified at:
    mock_stdio.cc:23:
        Function call: fprintf(0x3043dea0, 0x3043da80 pointing to "[2] ")
            Returns: 4
    */

    // Arrange
#if 1
    NiceMock<Mock_stdio> mock_stdio;
#else
    Mock_stdio mock_stdio;
#endif
    mock_stdio.switch_to_mock_fileio(); // ファイルアクセスに関する関数をすべてモックに差し替える

    // Pre-Assert
    EXPECT_CALL(mock_stdio, fclose(_, _, _, _))
        .WillOnce(InvokeWithoutArgs([]()
                                    { errno=EIO; return EOF; })); // 5: I/O error

    // Act
    int rtc = samplelogger(LOG_INFO, "%s\n", "fclose_failed");

    // Assert
    EXPECT_EQ(-1, rtc);
}
