#include <sampleinc.h>

int samplefunc2(const int a, const int b)
{
    int result;

    samplelogger(LOG_INFO, "samplefunc2 start a=%d, b=%d\n", a, b);
    result = a * b;
    samplelogger(LOG_INFO, "samplefunc2 end result=%d\n", result);
    return result;
}