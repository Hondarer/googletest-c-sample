#include <gmock/gmock.h>

#include <mock_stdio.h>

int mock_fflush_enable_trace = 0;

int delegate_real_fflush(FILE *fp)
{
    return fflush(fp);
}

int mock_fflush(const char *file, const int line, const char *func, FILE *fp)
{
    // avoid -Wunused-parameter
    (void)func;

    int rtc;

    if (_mock_stdio != nullptr)
    {
        rtc = _mock_stdio->fflush(file, line, func, fp);
    }
    else
    {
        rtc = delegate_real_fflush(fp);
    }
    
    if (mock_fflush_enable_trace != 0)
    {
        printf("  > fflush %d from %s:%d -> %d\n", fp->_fileno, file, line, rtc);
    }

    return rtc;
}
