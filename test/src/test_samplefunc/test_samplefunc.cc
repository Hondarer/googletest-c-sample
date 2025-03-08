#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include <test_com.h>
#include <mock_stdio.h>
#include <mock_sample.h>

#include <sampleinc.h>

using namespace testing;

class test_samplefunc : public Test
{
    void SetUp() override
    {
        resetTraceLevel();
        setTraceLevel("mock_samplelogger", TRACE_DETAIL);
    }
};

TEST_F(test_samplefunc, call_times_check)
{
    // Arrange
    Mock_sample mock_sample;

    // Pre-Assert
    // NOTE: シンプルにテスト全体で呼び出し回数だけをチェックするだけであれば、
    //       .Times を定義しておくだけでよい
    EXPECT_CALL(mock_sample, samplelogger(_, _))
        .Times(2);

    // Act
    int rtc = samplefunc(6, 2);

    // Assert
    EXPECT_EQ(3, rtc);
}

TEST_F(test_samplefunc, call_times_check_with_args)
{
    // Arrange
    Mock_sample mock_sample;

    // Pre-Assert
    // NOTE: InSequence 指定がない場合では、後に宣言されたルールから順に評価される。
    EXPECT_CALL(mock_sample, samplelogger(_, _))
        .Times(2); // samplelogger に "b is zero\n" 以外の呼び出しが 2 回あること
    EXPECT_CALL(mock_sample, samplelogger(_, StrEq("b is zero\n")))
        .Times(1); // samplelogger に "b is zero\n" の呼び出しが 1 回あること

    // Act
    int rtc = samplefunc(12, 0);

    // Assert
#ifdef DEBUG
    EXPECT_EQ(-2, rtc);
#else
    EXPECT_EQ(-1, rtc);
#endif
}
/* テストのコメント テスト結果にも載る */
TEST_F(test_samplefunc, will_without_InSequence)
{
    // Arrange
    Mock_sample mock_sample;

    // Pre-Assert
    // NOTE: InSequence 指定がない場合では、後に宣言されたルールから順に評価される。
    //       この場合、.Times と .Will... の混在は可能なるも、複雑なルールになるため注意が必要
    //       また、.Will... の場合、アクション (戻り値の設定) が必要
    EXPECT_CALL(mock_sample, samplelogger(_, _))
        .WillRepeatedly(DoDefault()); // samplelogger の既定の (下記以外の) 動作を定義
    EXPECT_CALL(mock_sample, samplelogger(_, StrEq("b is zero\n")))
        .WillOnce(DoDefault()); // samplelogger に "b is zero\n" の呼び出しが 1 回あること

    // Act
    int rtc = samplefunc(12, 0);

// Assert
#ifdef DEBUG
    EXPECT_EQ(-2, rtc);
#else
    EXPECT_EQ(-1, rtc);
#endif
}

TEST_F(test_samplefunc, times_with_InSequence)
{
    // Arrange
    InSequence seq;
    Mock_sample mock_sample;

    // Pre-Assert
    // NOTE: InSequence により、以下の呼び出し順序は行番号の順に評価されることが保証される
    EXPECT_CALL(mock_sample, samplelogger(_, _))
        .Times(1); // (1) samplelogger に呼び出しが 1 回あること
    EXPECT_CALL(mock_sample, samplelogger(_, StrEq("b is zero\n")))
        .Times(1); // (2) samplelogger に "b is zero\n" の呼び出しが 1 回あること
    EXPECT_CALL(mock_sample, samplelogger(_, _))
        .Times(1); // (3) samplelogger に呼び出しが 1 回あること

    // Act
    int rtc = samplefunc(12, 0);

// Assert
#ifdef DEBUG
    EXPECT_EQ(-2, rtc);
#else
    EXPECT_EQ(-1, rtc);
#endif
}

TEST_F(test_samplefunc, mix_with_InSequence)
{
    // Arrange
    InSequence seq;
    Mock_sample mock_sample;

    // Pre-Assert
    // NOTE: InSequence により、以下の呼び出し順序は行番号の順に評価されることが保証される
    EXPECT_CALL(mock_sample, samplelogger(_, _))
        .Times(1); // (1) samplelogger に呼び出しが 1 回あること
    EXPECT_CALL(mock_sample, samplelogger(_, StrEq("b is zero\n")))
        .WillOnce(DoDefault()); // (2) samplelogger に "b is zero\n" の呼び出しが 1 回あること
    EXPECT_CALL(mock_sample, samplelogger(_, _))
        .Times(1); // (3) samplelogger に呼び出しが 1 回あること

    // Act
    int rtc = samplefunc(12, 0);

// Assert
#ifdef DEBUG
    EXPECT_EQ(-2, rtc);
#else
    EXPECT_EQ(-1, rtc);
#endif
}
