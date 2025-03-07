#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include <test_com.h>
#include <mock_stdio.h>
#include <mock_sample.h>

#include <sampleinc.h>

using namespace testing;

class test_samplefunc2 : public Test
{
    void SetUp() override
    {
        clearTraceLevel();
        setTraceLevel("mock_samplelogger", TRACE_DETAIL);
    }
};

/*
LINK_SRCS_{C|CPP} で引用されている samplefunc2 は、テスト対象コードをそのまま利用する。
このパターンは、テストに関係ないユーティリティー関数をテスト内で利用したい場合に用いる。
カバレッジ対象とはならない。
*/

TEST_F(test_samplefunc2, call_test)
{
    // Arrange

    // Pre-Assert

    // Act
    int rtc = samplefunc2(6, 2);

    // Assert
    EXPECT_EQ(12, rtc);
}
