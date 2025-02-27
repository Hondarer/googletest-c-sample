#include <sampleinc.h>

int samplefunc(const int a, const int b)
{
    int result;

    samplelogger(LOG_INFO, "samplefunc start a=%d, b=%d\n", a, b);
    if (b == 0)
    {
        samplelogger(LOG_WARN, "b is zero\n");
        samplelogger(LOG_INFO, "samplefunc end result=%d\n", -1);
#ifdef DEBUG
        return -2;
#else
        return -1;
#endif
    }
    result = a / b;
    samplelogger(LOG_INFO, "samplefunc end result=%d\n", result);
    return result;
}