#include <gmock/gmock.h>

#include <test_com.h>
#include <mock_stdio.h>

using namespace testing;

FILE *delegate_real_fopen(const char *filename, const char *modes)
{
    return fopen(filename, modes);
}

FILE *mock_fopen(const char *file, const int line, const char *func, const char *filename, const char *modes)
{
    FILE *fp;

    if (_mock_stdio != nullptr)
    {
        fp = _mock_stdio->fopen(file, line, func, filename, modes);
    }
    else
    {
        fp = delegate_real_fopen(filename, modes);
    }

    if (getTraceLevel() > TRACE_NONE)
    {
        printf("  > fopen %s, %c", filename, *modes);
        if (getTraceLevel() >= TRACE_DETAIL)
        {
            if (fp == NULL)
            {
                printf(" from %s:%d -> NULL\n", file, line);
            }
            else
            {
                printf(" from %s:%d -> %d\n", file, line, fp->_fileno);
            }
        }
        else
        {
            printf("\n");
        }
    }

    return fp;
}
