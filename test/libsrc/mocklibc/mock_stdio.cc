#include <gmock/gmock.h>

#include <mock_stdio.h>

using namespace testing;

Mock_stdio *_mock_stdio = nullptr;

Mock_stdio::Mock_stdio()
{
    ON_CALL(*this, fclose(_))
        .WillByDefault(Invoke(delegate_real_fclose));

    ON_CALL(*this, fflush(_))
        .WillByDefault(Invoke(delegate_real_fflush));

    ON_CALL(*this, fopen(_, _))
        .WillByDefault(Invoke(delegate_real_fopen));

    ON_CALL(*this, fprintf(_, _))
        .WillByDefault(Invoke(delegate_real_fprintf));

    ON_CALL(*this, scanf(_, _))
        .WillByDefault(Invoke(delegate_real_scanf));

    _mock_stdio = this;
}

Mock_stdio::~Mock_stdio()
{
    _mock_stdio = nullptr;
}
