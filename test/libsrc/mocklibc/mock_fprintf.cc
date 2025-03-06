#include <gmock/gmock.h>

#include <test_com.h>
#include <mock_stdio.h>
#include <stdarg.h>

int mock_fprintf_enable_trace = 0;

int delegate_real_fprintf(FILE *stream, const char *str)
{
    return fprintf(stream, "%s", str);
}

int mock_fprintf(const char *file, const int line, const char *func, FILE *stream, const char *fmt, ...)
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
        rtc = _mock_stdio->fprintf(file, line, func, stream, str);
    }
    else
    {
        rtc = delegate_real_fprintf(stream, str);
    }

    if (mock_fprintf_enable_trace != 0)
    {
        size_t len = strlen(str);
        char *trimmed_str = (char *)malloc(len + 1);
        memcpy(trimmed_str, str, len + 1);
        if (trimmed_str != NULL)
        {
            if (len > 0 && trimmed_str[len - 1] == '\n')
            {
                trimmed_str[len - 1] = '\0';
            }
            printf("  > fprintf %d, %s from %s:%d -> %d\n", stream->_fileno, trimmed_str, file, line, rtc);
            free(trimmed_str);
        }
    }

    free(str);

    return rtc;
}
