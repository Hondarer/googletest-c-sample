#include <gmock/gmock.h>

#include <mock_stdlib.h>

using namespace testing;

Mock_stdlib *_mock_stdlib = nullptr;

Mock_stdlib::Mock_stdlib()
{
    ON_CALL(*this, calloc(_, _, _, _, _))
        .WillByDefault(Invoke([](Unused, Unused, Unused, size_t __nmemb, size_t __size) {
            return delegate_real_calloc(__nmemb, __size);
        }));

    _mock_stdlib = this;
}

Mock_stdlib::~Mock_stdlib()
{
    _mock_stdlib = nullptr;
}
