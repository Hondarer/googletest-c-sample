#include <gmock/gmock.h>

#include <mock_unistd.h>

int mock_access_enable_trace = 0;

int delegate_real_access(const char *path, int amode)
{
    return access(path, amode);
}

int mock_access(const char *file, const int line, const char *func, const char *path, int amode)
{
    int rtc;

    if (_mock_unistd != nullptr)
    {
        rtc = _mock_unistd->access(file, line, func, path, amode);
    }
    else
    {
        rtc = delegate_real_access(path, amode);
    }

    if (mock_access_enable_trace != 0)
    {
        printf("  > access %s, %d -> %d\n", path, amode, rtc);
    }

    return rtc;
}
