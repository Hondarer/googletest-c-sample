#include <gmock/gmock.h>
#include <gtest/gtest.h>

using namespace testing;

class MockClass3
{
public:
    MOCK_METHOD(int, myFunction, (int, int));

    MockClass3()
    {
        ON_CALL(*this, myFunction(_, _))
            .WillByDefault(Invoke([](int a, int b)
                                  { return a * b; })); // デフォルトのアクション
    }
};

class MockClass3Test : public TestWithParam<tuple<int, int, int>>
{
};

TEST_P(MockClass3Test, MultiplyTest)
{
    MockClass3 mockObj;

    int a = get<0>(GetParam());
    int b = get<1>(GetParam());
    int expected = get<2>(GetParam());

    EXPECT_CALL(mockObj, myFunction(a, b)).Times(1);

    int result = mockObj.myFunction(a, b);
    EXPECT_EQ(result, expected);
}

// NOTE: get_test_code.awk での構文解析の都合で、
//       INSTANTIATE_TEST_SUITE_P の行には
//       prefix (省略可能)、test_suite_name を同一行に記載し、
//       最後に "," を付与する。
INSTANTIATE_TEST_SUITE_P(, MockClass3Test,
                         Values(
                             make_tuple(1, 3, 3),
                             make_tuple(4, 1, 4)));

INSTANTIATE_TEST_SUITE_P(MultiplicationTests1, MockClass3Test,
                         Values(
                             make_tuple(2, 3, 6),
                             make_tuple(4, 5, 20)));

INSTANTIATE_TEST_SUITE_P(MultiplicationTests2, MockClass3Test,
                         Values(
                             make_tuple(3, 2, 6),
                             make_tuple(5, 4, 20)));
