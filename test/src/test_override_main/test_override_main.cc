#include <gmock/gmock.h>
#include <gtest/gtest.h>
#include <gtest_wrapmain.h>

using namespace testing;

class test_override_main : public Test
{
};

TEST_F(test_override_main, test)
{
    // Arrange
    int argc = 1;
    const char *argv[] = {"test_samplefunc"};

    // Pre-Assert

    // Act
    int rtc = __real_main(argc, (char **)&argv);

    // Assert
    EXPECT_EQ(123, rtc);
}
