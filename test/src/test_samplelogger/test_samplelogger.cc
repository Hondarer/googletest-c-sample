#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-parameter"

#include <sampleinc.h>
#include <gtest/gtest.h>
#include <mock_stdio.h>

using namespace testing;

class test_samplelogger : public Test
{
    void SetUp() override
    {
        mock_fopen_enable_trace = 1;
        mock_fclose_enable_trace = 1;
    }

    void TearDown() override
    {
    }
};

TEST_F(test_samplelogger, normal_call)
{
    // Arrange
    Mock_fopen mock_fopen;

    // Pre-Assert
    EXPECT_CALL(mock_fopen, fopen(_, _))
        .Times(1);

    // Act
    int rtc = samplelogger(LOG_INFO, "%s\n", "normal_call");

    // Assert
    EXPECT_EQ(rtc, 12);
}

TEST_F(test_samplelogger, fopen_failed)
{
    // Arrange
    Mock_fopen mock_fopen;

    // Pre-Assert
    EXPECT_CALL(mock_fopen, fopen(_, _))
        .WillOnce(Return(nullptr));

    // Act
    int rtc = samplelogger(LOG_INFO, "%s\n", "fopen_failed");

    // Assert
    EXPECT_EQ(rtc, -1);
}

TEST_F(test_samplelogger, fclose_failed)
{
    // Arrange
    Mock_fclose mock_fclose;

    // Pre-Assert
    EXPECT_CALL(mock_fclose, fclose(_))
        .WillOnce(Invoke([](FILE *fp)
                         { errno=5; return EOF; }));

    // Act
    int rtc = samplelogger(LOG_INFO, "%s\n", "fclose_failed");

    // Assert
    EXPECT_EQ(rtc, -1);
}

#pragma GCC diagnostic pop
