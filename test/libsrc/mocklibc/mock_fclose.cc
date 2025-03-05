#include <gmock/gmock.h>

#include <mock_stdio.h>

int mock_fclose_enable_trace = 0;

int delegate_real_fclose(FILE *fp)
{
    return fclose(fp);
}

int mock_fclose(const char *file, const int line, const char *func, FILE *fp)
{
    // avoid -Wunused-parameter
    (void)func;

    int rtc;
    int fileno = fp->_fileno; // fclose 内にて初期化されるため、退避

    if (_mock_stdio != nullptr)
    {
        rtc = _mock_stdio->fclose(file, line, func, fp);
    }
    else
    {
        rtc = delegate_real_fclose(fp);
    }
    
    if (mock_fclose_enable_trace != 0)
    {
        printf("  > fclose %d from %s:%d -> %d\n", fileno, file, line, rtc);
    }

    return rtc;
}
