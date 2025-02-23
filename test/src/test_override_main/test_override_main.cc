#include <gmock/gmock.h>
#include <gtest/gtest.h>

extern "C" int samplefunc(void);

using namespace testing;

class test_samplefunc : public Test
{
};

TEST_F(test_samplefunc, test)
{
    // Arrange

    // Pre-Assert

    // Act
    int rtc = samplefunc();

    // Assert
    EXPECT_EQ(123, rtc);
}
