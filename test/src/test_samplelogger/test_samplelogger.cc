#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include <mock_stdio.h>

#include <sampleinc.h>

using namespace testing;

class test_samplelogger : public Test
{
    void SetUp() override
    {
        mock_fclose_enable_trace = 1;
        mock_fflush_enable_trace = 1;
        mock_fopen_enable_trace = 1;
        mock_fprintf_enable_trace = 1;
    }
};

TEST_F(test_samplelogger, normal_call)
{
    // Arrange
    NiceMock<Mock_stdio> mock_stdio; // 宣言のないデフォルト Mock への呼び出し警告をしない

    // Pre-Assert
    EXPECT_CALL(mock_stdio, fopen(_, _))
        .Times(1);

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
    EXPECT_CALL(mock_stdio, fopen(_, _))
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

    GMOCK WARNING:
    Uninteresting mock function call - taking default action specified at:
    mock_stdio.cc:20:
        Function call: fopen(0x47ef52 pointing to "/tmp/sample.log", 0x47ef50 pointing to "a")
            Returns: 0x3043dea0
    NOTE: You can safely ignore the above warning unless this call should not happen.  Do not suppress it by blindly adding an EXPECT_CALL() if you don't mean to enforce the call.  See https://github.com/google/googletest/blob/main/docs/gmock_cook_book.md#knowing-when-to-expect-useoncall for details.
    > fopen /tmp/sample.log, a -> 3

    GMOCK WARNING:
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

#if 1
    // Pre-Assert
    EXPECT_CALL(mock_stdio, fopen(_, _))
        .Times(1);
    EXPECT_CALL(mock_stdio, fprintf(_, _))
        .Times(1);
#else
    // Pre-Assert
#endif
    EXPECT_CALL(mock_stdio, fclose(_))
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

    GMOCK WARNING:
    Uninteresting mock function call - taking default action specified at:
    mock_stdio.cc:20:
        Function call: fopen(0x47ef52 pointing to "/tmp/sample.log", 0x47ef50 pointing to "a")
            Returns: 0x3043dea0
    NOTE: You can safely ignore the above warning unless this call should not happen.  Do not suppress it by blindly adding an EXPECT_CALL() if you don't mean to enforce the call.  See https://github.com/google/googletest/blob/main/docs/gmock_cook_book.md#knowing-when-to-expect-useoncall for details.
    > fopen /tmp/sample.log, a -> 3

    GMOCK WARNING:
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

    // Pre-Assert
    EXPECT_CALL(mock_stdio, fclose(_))
        .WillOnce(InvokeWithoutArgs([]()
                                    { errno=EIO; return EOF; })); // 5: I/O error

    // Act
    int rtc = samplelogger(LOG_INFO, "%s\n", "fclose_failed");

    // Assert
    EXPECT_EQ(-1, rtc);
}
