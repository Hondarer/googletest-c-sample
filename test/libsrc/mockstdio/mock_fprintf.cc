#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wpadded"
#include <gmock/gmock.h>
#pragma GCC diagnostic pop

#include <test_com.h>
#include <mock_stdio.h>
#include <stdarg.h>

using namespace testing;

static Mock_fprintf *_mock_fprintf = nullptr;

int mock_fprintf_enable_trace = 0;

Mock_fprintf::Mock_fprintf()
{
    ON_CALL(*this, fprintf(_, _))
        .WillByDefault(Invoke(delegate_real_fprintf));
    _mock_fprintf = this;
}

Mock_fprintf::~Mock_fprintf()
{
    _mock_fprintf = nullptr;
}

// 実際の fprintf 関数を呼び出すモッククラスの中継メソッド
int delegate_real_fprintf(FILE *stream, const char *str)
{
    return fprintf(stream, "%s", str);
}

// モックされた`fprintf`関数
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
    else if (_mock_fprintf != nullptr)
    {
        rtc = _mock_fprintf->fprintf(stream, str);
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
