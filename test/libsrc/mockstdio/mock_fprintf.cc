#include <gmock/gmock.h>

#include <test_com.h>
#include <mock_stdio.h>
#include <stdarg.h>

using namespace testing;

int mock_fprintf_enable_trace = 0;

int delegate_real_fprintf(FILE *stream, const char *str)
{
    return fprintf(stream, "%s", str);
}

int mock_fprintf(FILE *stream, const char *fmt, ...)
{
    va_list args;
    char *str;
    int rtc;

    // 可変引数リストを初期化
    va_start(args, fmt);

    str = allocvprintf(fmt, args);
    va_end(args);

    if (str == NULL)
    {
        rtc = -1;
    }
    else if (_mock_stdio != nullptr)
    {
        rtc = _mock_stdio->fprintf(stream, str);
    }
    else
    {
        rtc = delegate_real_fprintf(stream, str);
    }

    if (mock_fprintf_enable_trace != 0)
    {
        printf("  > fprintf %d, %s -> %d\n", stream->_fileno, str, rtc);
    }

    free(str);

    return rtc;
}
