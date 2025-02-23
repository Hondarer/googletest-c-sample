#include <gmock/gmock.h>
#include <gtest/gtest.h>

using namespace std;
using namespace testing;

class MockClass5
{
public:
    MOCK_METHOD(int, myFunction, (int, int));

    MockClass5()
    {
        ON_CALL(*this, myFunction(_, _))
            .WillByDefault(Invoke([](int a, int b)
                                  { return a * b; })); // デフォルトのアクション
    }
};

class MockClass5Test : public TestWithParam<tuple<string, int, int, int>>
{
};

TEST_P(MockClass5Test, MultiplyTest)
{
    MockClass5 mockObj;

    string s = get<0>(GetParam());
    int a = get<1>(GetParam());
    int b = get<2>(GetParam());
    int expected = get<3>(GetParam());

    // cout~endl
    // cout<<s<<endl;

    // printf (char*)
    printf("%s\n", s.c_str());

    EXPECT_CALL(mockObj, myFunction(a, b)).Times(1);

    int result = mockObj.myFunction(a, b);
    EXPECT_EQ(result, expected);
}

// NOTE: get_test_code.awk での構文解析の都合で、
//       INSTANTIATE_TEST_SUITE_P の行には
//       prefix (省略可能)、test_suite_name を同一行に記載し、
//       最後に "," を付与する。
INSTANTIATE_TEST_SUITE_P(, MockClass5Test,
                         Values(
                             make_tuple("test1", 1, 3, 3),
                             make_tuple("test2", 4, 1, 4)));

INSTANTIATE_TEST_SUITE_P(MultiplicationTests1, MockClass5Test,
                         Values(
                             make_tuple("test2-1", 2, 3, 6),
                             make_tuple("test2-2", 4, 5, 20)));

// テスト名をカスタマイズする例
INSTANTIATE_TEST_SUITE_P(MultiplicationTests2, MockClass5Test,
                         Values(
                             make_tuple("test3_1", 3, 2, 6),
                             make_tuple("test3_2", 5, 4, 20)),
                         [](const TestParamInfo<tuple<string, int, int, int>> &paraminfo)
                         {
                             const auto &param = paraminfo.param;
                             // NOTE: テスト名のルールは以下の制約がある
                             //       NOT contains spaces, dashes, or any non-alphanumeric characters other than underscores
                             return string(get<0>(param) + "_" +
                                           to_string(get<1>(param)) + "_" +
                                           to_string(get<2>(param)) + "_" +
                                           to_string(get<3>(param)));
                         });
