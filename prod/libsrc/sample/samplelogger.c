#include <sampleinc.h>
#include <stdio.h>
#include <stdarg.h>

int samplelogger(const int lvl, const char *fmt, ...)
{
    va_list args;
    int rtc;

    FILE *fp = fopen("/tmp/sample.log", "a");
    if (fp == NULL)
    {
        return -1;
    }

    fprintf(fp, "[%d] ", lvl);

    va_start(args, fmt);
    rtc = vfprintf(fp, fmt, args);
    va_end(args);

    if (fclose(fp) == EOF)
    {
        return -1;
    }

    return rtc;
}
