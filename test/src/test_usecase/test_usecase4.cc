#include <gmock/gmock.h>
#include <gtest/gtest.h>

using namespace std;
using namespace testing;

class MockClass4
{
public:
    MOCK_METHOD(int, myFunction, (int, int));

    MockClass4()
    {
        ON_CALL(*this, myFunction(_, _))
            .WillByDefault(Invoke([](int a, int b)
                                  { return a * b; })); // デフォルトのアクション
    }
};

// see https://kkayataka.hatenablog.com/entry/2020/07/26/115813
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wpadded"
struct MockClass4TestParam
{
    string desc;
    int a;
    int b;
    int expected;

    MockClass4TestParam(
        const string &_desc,
        const int _a,
        const int _b,
        const int _expected) : desc(_desc),
                               a(_a),
                               b(_b),
                               expected(_expected)
    {
    }
};
#pragma GCC diagnostic pop

ostream &operator<<(ostream &, const MockClass4TestParam &);
ostream &operator<<(ostream &stream, const MockClass4TestParam &p)
{
    return stream << p.desc;
}

class MockClass4Test : public TestWithParam<MockClass4TestParam>
{
};

TEST_P(MockClass4Test, MultiplyTest)
{
    MockClass4 mockObj;
    const MockClass4TestParam p = GetParam();

    EXPECT_CALL(mockObj, myFunction(p.a, p.b)).Times(1);

    int result = mockObj.myFunction(p.a, p.b);
    EXPECT_EQ(result, p.expected);
}

// テスト名をデータ定義できるようにする例
INSTANTIATE_TEST_SUITE_P(, MockClass4Test,
                         Values(
                             MockClass4TestParam("2_3_6", 2, 3, 6),
                             MockClass4TestParam("4_5_20", 4, 5, 20)),
                         PrintToStringParamName());
