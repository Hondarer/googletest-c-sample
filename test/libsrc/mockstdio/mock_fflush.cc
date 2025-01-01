#include <mock_stdio.h>

using namespace testing;

static Mock_fflush *_mock_fflush = nullptr;

int mock_fflush_enable_trace = 0;

Mock_fflush::Mock_fflush()
{
    ON_CALL(*this, fflush(_))
        .WillByDefault(Invoke(delegate_real_fflush));
    _mock_fflush = this;
}

Mock_fflush::~Mock_fflush()
{
    _mock_fflush = nullptr;
}

int delegate_real_fflush(FILE *fp)
{
    return fflush(fp);
}

int mock_fflush(FILE *fp)
{
    int rtc;
    if (_mock_fflush != nullptr)
    {
        rtc = _mock_fflush->fflush(fp);
    }
    else
    {
        rtc = delegate_real_fflush(fp);
    }
    if (mock_fflush_enable_trace != 0)
    {
        printf("  > fflush %d -> %d\n", fp->_fileno, rtc);
    }

    return rtc;
}
