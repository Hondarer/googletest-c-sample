#include <gmock/gmock.h>

#include <mock_stdio.h>

int mock_fopen_enable_trace = 0;

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
    
    if (mock_fopen_enable_trace != 0)
    {
        if (fp == NULL)
        {
            printf("  > fopen %s, %c from %s:%d -> NULL\n", filename, *modes, file, line);
        }
        else
        {
            printf("  > fopen %s, %c from %s:%d -> %d\n", filename, *modes, file, line, fp->_fileno);
        }
    }

    return fp;
}
