
#include <gmock/gmock.h>
#include <gtest/gtest.h>

using namespace testing;

class MockClass1
{
public:
    MOCK_METHOD(int, myFunction, ());
};

TEST(TestUsecase, any_times_with_return_sequential)
{
    InSequence seq; // EXPECT_CALL が順に評価されることを宣言
    MockClass1 mock;

    EXPECT_CALL(mock, myFunction())
        .Times(3)
        .WillRepeatedly(Return(123)); // 1~3 回目の呼び出しでは 123 を返す

    EXPECT_CALL(mock, myFunction())
        .Times(2)
        .WillRepeatedly(Return(456)); // 4~5 回目の呼び出しでは 456 を返す

    // テスト
    EXPECT_EQ(mock.myFunction(), 123); // 1回目
    EXPECT_EQ(mock.myFunction(), 123); // 2回目
    EXPECT_EQ(mock.myFunction(), 123); // 3回目
    EXPECT_EQ(mock.myFunction(), 456); // 4回目
    EXPECT_EQ(mock.myFunction(), 456); // 5回目
}
