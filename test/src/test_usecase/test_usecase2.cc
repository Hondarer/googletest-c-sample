
#include <gmock/gmock.h>
#include <gtest/gtest.h>

using namespace testing;

class MockClass2
{
public:
    MOCK_METHOD(int, myFunction, (int, int));

    MockClass2()
    {
        ON_CALL(*this, myFunction(_, _))
            .WillByDefault(Return(123)); // デフォルトのアクション
    }
};

TEST(TestUsecase, use_default_action)
{
    InSequence seq; // EXPECT_CALL が順に評価されることを宣言
    MockClass2 mock;

    EXPECT_CALL(mock, myFunction(_, _))
        .Times(2)
        .WillRepeatedly(Return(0)); // 1~2 回目の呼び出しでは 123 を返す

    EXPECT_CALL(mock, myFunction(_, _))
        .Times(2)
        .WillRepeatedly(DoDefault()); // 3~4 回目の呼び出しではデフォルトのアクションを行う

    EXPECT_CALL(mock, myFunction(_, _))
        .WillOnce(Return(567)); // 5 回目の呼び出しでは 567 を返す

    // テスト
    EXPECT_EQ(0, mock.myFunction(1, 2));   // 1回目
    EXPECT_EQ(0, mock.myFunction(2, 3));   // 2回目
    EXPECT_EQ(123, mock.myFunction(3, 4)); // 3回目
    EXPECT_EQ(123, mock.myFunction(4, 5)); // 4回目
    EXPECT_EQ(567, mock.myFunction(5, 6)); // 5回目
}

TEST(TestUsecase, use_lambda_action)
{
    MockClass2 mock;

    EXPECT_CALL(mock, myFunction(_, _))
        .Times(2)
        .WillRepeatedly(Invoke([](int a, int b)
                               { return a * b; })); // 1~2 回目の呼び出しでは a * b を返す

    // テスト
    EXPECT_EQ(2, mock.myFunction(1, 2)); // 1回目
    EXPECT_EQ(6, mock.myFunction(2, 3)); // 2回目
}

static int myFunctionImpl(int, int);
static int myFunctionImpl(int a, int b)
{
    return a + b;
}

TEST(TestUsecase, use_exists_method)
{
    MockClass2 mock;

    EXPECT_CALL(mock, myFunction(_, _))
        .WillOnce(DoDefault())             // 1回目の呼び出しではデフォルトのアクションを行う
        .WillOnce(Invoke(myFunctionImpl)); // 2 回目の呼び出しでは a + b を返す

    // テスト
    EXPECT_EQ(123, mock.myFunction(1, 2)); // 1回目
    EXPECT_EQ(5, mock.myFunction(2, 3));   // 2回目
}
