#include <gmock/gmock.h>

#include <mock_stdio.h>

int mock_fflush_enable_trace = 0;

int delegate_real_fflush(FILE *fp)
{
    return fflush(fp);
}

int mock_fflush(FILE *fp)
{
    int rtc;

    if (_mock_stdio != nullptr)
    {
        rtc = _mock_stdio->fflush(fp);
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
