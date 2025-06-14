
#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include "testfunc.h"
#include "mock_factory.h"

using namespace testing;

TEST(dev_mock_c_method, test_dev_mock_c_method)
{
    // Arrange
    Mock_func1 mock_func1;

    // Pre-Assert
    EXPECT_CALL(mock_func1, func1(1, 2))
        .WillOnce(Return(2));

    // Act
    int rtc = testfunc_entry(1);

    // Assert
    EXPECT_EQ(2, rtc);
}
