#include <gmock/gmock.h>

#include <mock_string.h>

using namespace testing;

Mock_string *_mock_string = nullptr;

Mock_string::Mock_string()
{
    ON_CALL(*this, memset(_, _, _, _, _, _))
        .WillByDefault(Invoke([](Unused, Unused, Unused, void *s, int c, size_t n)
                              { return delegate_real_memset(s, c, n); }));

    _mock_string = this;
}

Mock_string::~Mock_string()
{
    _mock_string = nullptr;
}
