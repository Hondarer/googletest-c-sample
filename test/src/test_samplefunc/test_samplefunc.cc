#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-parameter"

#include <sampleinc.h>
#include <gtest/gtest.h>
#include <mock_sample.h>

using namespace testing;

class test_samplefunc : public Test
{
    void SetUp() override
    {
        mock_samplelogger_enable_trace = 1;
    }

    void TearDown() override
    {
    }
};

TEST_F(test_samplefunc, call_times_check)
{
    // Arrange
    Mock_samplelogger mock_samplelogger;

    // Pre-Assert
    // NOTE: シンプルにテスト全体で呼び出し回数だけをチェックするだけであれば、
    //       .Times を定義しておくだけでよい
    EXPECT_CALL(mock_samplelogger, samplelogger(_, _))
        .Times(2);

    // Act
    int rtc = samplefunc(6, 2);

    // Assert
    EXPECT_EQ(rtc, 3);
}

TEST_F(test_samplefunc, call_times_check_with_args)
{
    // Arrange
    Mock_samplelogger mock_samplelogger;

    // Pre-Assert
    // NOTE: InSequence 指定がない場合では、後に宣言されたルールから順に評価される。
    EXPECT_CALL(mock_samplelogger, samplelogger(_, _))
        .Times(2); // samplelogger に "b is zero\n" 以外の呼び出しが 2 回あること
    EXPECT_CALL(mock_samplelogger, samplelogger(_, StrEq("b is zero\n")))
        .Times(1); // samplelogger に "b is zero\n" の呼び出しが 1 回あること

    // Act
    int rtc = samplefunc(12, 0);

    // Assert
    EXPECT_EQ(rtc, -1);
}
TEST_F(test_samplefunc, will_without_InSequence)
{
    // Arrange
    Mock_samplelogger mock_samplelogger;

    // Pre-Assert
    // NOTE: InSequence 指定がない場合では、後に宣言されたルールから順に評価される。
    //       この場合、.Times と .Will... の混在は可能なるも、複雑なルールになるため注意が必要
    //       また、.Will... の場合、アクション (戻り値の設定) が必要
    EXPECT_CALL(mock_samplelogger, samplelogger(_, _))
        .WillRepeatedly(Invoke([](int level, const char *message)
                               { return strlen(message); })); // samplelogger の既定の (下記以外の) 動作を定義
    EXPECT_CALL(mock_samplelogger, samplelogger(_, StrEq("b is zero\n")))
        .WillOnce(Invoke([](int level, const char *message)
                         { return strlen(message); })); // samplelogger に "b is zero\n" の呼び出しが 1 回あること

    // Act
    int rtc = samplefunc(12, 0);

    // Assert
    EXPECT_EQ(rtc, -1);
}

TEST_F(test_samplefunc, times_with_InSequence)
{
    // Arrange
    InSequence seq;
    Mock_samplelogger mock_samplelogger;

    // Pre-Assert
    // NOTE: InSequence により、以下の呼び出し順序は行番号の順に評価されることが保証される
    EXPECT_CALL(mock_samplelogger, samplelogger(_, _))
        .Times(1); // (1) samplelogger に呼び出しが 1 回あること
    EXPECT_CALL(mock_samplelogger, samplelogger(_, StrEq("b is zero\n")))
        .Times(1); // (2) samplelogger に "b is zero\n" の呼び出しが 1 回あること
    EXPECT_CALL(mock_samplelogger, samplelogger(_, _))
        .Times(1); // (3) samplelogger に呼び出しが 1 回あること

    // Act
    int rtc = samplefunc(12, 0);

    // Assert
    EXPECT_EQ(rtc, -1);
}

TEST_F(test_samplefunc, mix_with_InSequence)
{
    // Arrange
    InSequence seq;
    Mock_samplelogger mock_samplelogger;

    // Pre-Assert
    // NOTE: InSequence により、以下の呼び出し順序は行番号の順に評価されることが保証される
    EXPECT_CALL(mock_samplelogger, samplelogger(_, _))
        .Times(1); // (1) samplelogger に呼び出しが 1 回あること
    EXPECT_CALL(mock_samplelogger, samplelogger(_, StrEq("b is zero\n")))
        .WillOnce(Invoke([](int level, const char *message)
                         { return strlen(message); })); // (2) samplelogger に "b is zero\n" の呼び出しが 1 回あること
    EXPECT_CALL(mock_samplelogger, samplelogger(_, _))
        .Times(1); // (3) samplelogger に呼び出しが 1 回あること

    // Act
    int rtc = samplefunc(12, 0);

    // Assert
    EXPECT_EQ(rtc, -1);
}

#pragma GCC diagnostic pop
