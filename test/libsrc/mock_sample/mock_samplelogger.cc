#include <gmock/gmock.h>

#include <test_com.h>
#include <mock_sample.h>

#include <sampleinc.h>

using namespace testing;

int samplelogger(const int lvl, const char *fmt, ...)
{
    va_list args;
    char *str;
    int rtc = 0;

    va_start(args, fmt);
    str = allocvprintf(fmt, args);
    va_end(args);

    if (str == NULL)
    {
        return -1;
    }

    if (_mock_sample != nullptr)
    {
        rtc = _mock_sample->samplelogger(lvl, str);
    }

    if (getTraceLevel() > TRACE_NONE)
    {
        // '\n' で終わっている場合はトレースが見にくくなるので `\n` を削除
        size_t len = strlen(str);
        if (len > 0 && str[len - 1] == '\n')
        {
            str[len - 1] = '\0';
        }

        printf("  > samplelogger %d, %s", lvl, str);
        if (getTraceLevel() >= TRACE_DETAIL)
        {
            printf(" -> %d\n", rtc);
        }
        else
        {
            printf("\n");
        }
    }

    free(str);

    return rtc;
}
