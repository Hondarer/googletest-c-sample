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
    NiceMock<Mock_stdio> mock_stdio; // 宣言のないデフォルト Mock への呼び出し警告をしない

    // ダミーの fp
    FILE fp;
    memset(&fp, 0x00, sizeof(fp));
    fp._fileno = 1;

    // Pre-Assert
    // すべてのファイル入出力を入れ替えてテスト
    EXPECT_CALL(mock_stdio, fopen(_, _, _, StrEq("/tmp/sample.log"), StrEq("a")))
        .WillOnce(Return(&fp));

    EXPECT_CALL(mock_stdio, fprintf(_, _, _, &fp, _))
        .WillOnce(Invoke([](Unused, Unused, Unused, FILE *stream, const char *str)
                         { return delegate_fake_fprintf(stream, str); }));

    EXPECT_CALL(mock_stdio, vfprintf(_, _, _, &fp, _))
        .WillOnce(Invoke([](Unused, Unused, Unused, FILE *stream, const char *str)
                         { return delegate_fake_vfprintf(stream, str); }));

    EXPECT_CALL(mock_stdio, fclose(_, _, _, &fp))
        .WillOnce(Return(0));

    // Act
    int rtc = samplelogger(LOG_INFO, "%s\n", "normal_call");

    // Assert
    EXPECT_EQ(12, rtc);
}

TEST_F(test_samplelogger, fopen_failed)
{
    // Arrange
    Mock_stdio mock_stdio;

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
    NOTE: You can safely ignore the above warning unless this call should not happen.  Do not suppress it by blindly adding an EXPECT_CALL() if you don't mean to enforce the call.  See https://github.com/google/googletest/blob/main/docs/gmock_cook_book.md#knowing-when-to-expect-useoncall for details.
    > fopen /tmp/sample.log, a -> 3

    Uninteresting mock function call - taking default action specified at:
    mock_stdio.cc:23:
        Function call: fprintf(0x3043dea0, 0x3043da80 pointing to "[2] ")
            Returns: 4
    NOTE: You can safely ignore the above warning unless this call should not happen.  Do not suppress it by blindly adding an EXPECT_CALL() if you don't mean to enforce the call.  See https://github.com/google/googletest/blob/main/docs/gmock_cook_book.md#knowing-when-to-expect-useoncall for details.
    > fprintf 3, [2]  -> 4
    > fclose 3 -> -1
    */

    // Arrange
    Mock_stdio mock_stdio;

    // ダミーの fp
    FILE fp;
    memset(&fp, 0x00, sizeof(fp));
    fp._fileno = 1;

#if 1
    // Pre-Assert
    EXPECT_CALL(mock_stdio, fopen(_, _, _, StrEq("/tmp/sample.log"), StrEq("a")))
        .WillOnce(Return(&fp));

    EXPECT_CALL(mock_stdio, fprintf(_, _, _, &fp, _))
        .WillOnce(Invoke([](Unused, Unused, Unused, FILE *stream, const char *str)
                         { return delegate_fake_fprintf(stream, str); }));

    EXPECT_CALL(mock_stdio, vfprintf(_, _, _, &fp, _))
        .WillOnce(Invoke([](Unused, Unused, Unused, FILE *stream, const char *str)
                         { return delegate_fake_vfprintf(stream, str); }));
#else
    // Pre-Assert
#endif
    EXPECT_CALL(mock_stdio, fclose(_, _, _, &fp))
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
    NOTE: You can safely ignore the above warning unless this call should not happen.  Do not suppress it by blindly adding an EXPECT_CALL() if you don't mean to enforce the call.  See https://github.com/google/googletest/blob/main/docs/gmock_cook_book.md#knowing-when-to-expect-useoncall for details.
    > fopen /tmp/sample.log, a -> 3

    Uninteresting mock function call - taking default action specified at:
    mock_stdio.cc:23:
        Function call: fprintf(0x3043dea0, 0x3043da80 pointing to "[2] ")
            Returns: 4
    NOTE: You can safely ignore the above warning unless this call should not happen.  Do not suppress it by blindly adding an EXPECT_CALL() if you don't mean to enforce the call.  See https://github.com/google/googletest/blob/main/docs/gmock_cook_book.md#knowing-when-to-expect-useoncall for details.
    > fprintf 3, [2]  -> 4
    > fclose 3 -> -1
    */

    // Arrange
#if 1
    NiceMock<Mock_stdio> mock_stdio;
#else
    Mock_stdio mock_stdio;
#endif

    // ダミーの fp
    FILE fp;
    memset(&fp, 0x00, sizeof(fp));
    fp._fileno = 1;

    // Pre-Assert
    EXPECT_CALL(mock_stdio, fopen(_, _, _, StrEq("/tmp/sample.log"), StrEq("a")))
        .WillOnce(Return(&fp));

    EXPECT_CALL(mock_stdio, fprintf(_, _, _, &fp, _))
        .WillOnce(Invoke([](Unused, Unused, Unused, FILE *stream, const char *str)
                         { return delegate_fake_fprintf(stream, str); }));

    EXPECT_CALL(mock_stdio, vfprintf(_, _, _, &fp, _))
        .WillOnce(Invoke([](Unused, Unused, Unused, FILE *stream, const char *str)
                         { return delegate_fake_vfprintf(stream, str); }));

    EXPECT_CALL(mock_stdio, fclose(_, _, _, &fp))
        .WillOnce(InvokeWithoutArgs([]()
                                    { errno=EIO; return EOF; })); // 5: I/O error

    // Act
    int rtc = samplelogger(LOG_INFO, "%s\n", "fclose_failed");

    // Assert
    EXPECT_EQ(-1, rtc);
}
