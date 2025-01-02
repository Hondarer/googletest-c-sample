#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-parameter"

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wpadded"
#include <gmock/gmock.h>
#include <gtest/gtest.h>
#pragma GCC diagnostic pop

#include <mock_stdio.h>

#include <sampleinc.h>

using namespace testing;

class test_samplelogger : public Test
{
protected:
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
    Mock_stdio mock_stdio;

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

TEST_F(test_samplelogger, fclose_failed)
{
    // Arrange
    Mock_stdio mock_stdio;

    // Pre-Assert
    EXPECT_CALL(mock_stdio, fclose(_))
        .WillOnce(InvokeWithoutArgs([]()
                                    { errno=EIO; return EOF; })); // 5: I/O error

    // Act
    int rtc = samplelogger(LOG_INFO, "%s\n", "fclose_failed");

    // Assert
    EXPECT_EQ(-1, rtc);
}

#pragma GCC diagnostic pop
