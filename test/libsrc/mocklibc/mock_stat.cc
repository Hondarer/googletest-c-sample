#include <gmock/gmock.h>

#include <sys/mock_stat.h>

int mock_stat_enable_trace = 0;

int delegate_real_stat(const char *path, struct stat *buf)
{
    return stat(path, buf);
}

int mock_stat(const char *path, struct stat *buf)
{
    int rtc;

    if (_mock_sys_stat != nullptr)
    {
        rtc = _mock_sys_stat->stat(path, buf);
    }
    else
    {
        rtc = delegate_real_stat(path, buf);
    }
    
    if (mock_stat_enable_trace != 0)
    {
        printf("  > stat %s -> %d\n", path, rtc);
    }

    return rtc;
}
