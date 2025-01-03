#include <gmock/gmock.h>

#include <mock_stdio.h>

int mock_fclose_enable_trace = 0;

int delegate_real_fclose(FILE *fp)
{
    return fclose(fp);
}

int mock_fclose(FILE *fp)
{
    int rtc;
    int fileno = fp->_fileno; // fclose 内にて初期化されるため、退避

    if (_mock_stdio != nullptr)
    {
        rtc = _mock_stdio->fclose(fp);
    }
    else
    {
        rtc = delegate_real_fclose(fp);
    }
    
    if (mock_fclose_enable_trace != 0)
    {
        printf("  > fclose %d -> %d\n", fileno, rtc);
    }

    return rtc;
}
