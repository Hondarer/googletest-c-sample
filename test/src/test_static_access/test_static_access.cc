#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include <mock_stdio.h>
#include <mock_sample.h>

#include <sampleinc.h>

#include "inject.h"

using namespace testing;

class test_static_access : public Test
{
};

TEST_F(test_static_access, test)
{
    // Arrange
    set_static_int(123);

    // Pre-Assert

    // Act
    int rtc = samplestatic();

    // Assert
    EXPECT_EQ(123, rtc);
}
