#include <gmock/gmock.h>

#include <test_com.h>
#include <mock_sample.h>

using namespace testing;

Mock_sample *_mock_sample = nullptr;

Mock_sample::Mock_sample()
{
    ON_CALL(*this, samplelogger(_, _))
        .WillByDefault(Invoke([](Unused, const char *str)
                              { return strlen(str); })); // NOTE: Unused を使うと未使用である旨が明確になる

    _mock_sample = this;
}

Mock_sample::~Mock_sample()
{
    _mock_sample = nullptr;
}
