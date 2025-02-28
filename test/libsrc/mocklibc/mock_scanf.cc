#include <gmock/gmock.h>

#include <test_com.h>
#include <mock_stdio.h>
#include <stdarg.h>

int mock_scanf_enable_trace = 0;

int delegate_real_scanf(const char * format, va_list arg_ptr)
{
    return vscanf(format, arg_ptr);
}

int mock_scanf(const char *fmt, ...)
{
    va_list args;
    int rtc;

    // 可変引数リストを初期化
    va_start(args, fmt);

    if (_mock_stdio != nullptr)
    {
        rtc = _mock_stdio->scanf(fmt, args);
    }
    else
    {
        rtc = delegate_real_scanf(fmt, args);
    }

    va_end(args);

    if (mock_scanf_enable_trace != 0)
    {
        // TODO:
    }

    return rtc;
}
