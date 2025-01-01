#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-parameter"

#include <test_com.h>
#include <mock_sample.h>

using namespace testing;

static Mock_samplelogger *_mock_samplelogger = nullptr;

int mock_samplelogger_enable_trace = 0;

Mock_samplelogger::Mock_samplelogger()
{
    ON_CALL(*this, samplelogger(_, _))
        .WillByDefault(Invoke([](const int lvl, const char *str)
                              { return strlen(str); }));
    _mock_samplelogger = this;
}

Mock_samplelogger::~Mock_samplelogger()
{
    _mock_samplelogger = nullptr;
}

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

    if (mock_samplelogger_enable_trace != 0)
    {
        printf("  > samplelogger %d, %s", lvl, str);
    }
    if (_mock_samplelogger != nullptr)
    {
        rtc = _mock_samplelogger->samplelogger(lvl, str);
    }
    free(str);
    return rtc;
}

#pragma GCC diagnostic pop
