#include <gmock/gmock.h>

#include <mock_stdio.h>

int mock_fopen_enable_trace = 0;

FILE *delegate_real_fopen(const char *filename, const char *modes)
{
    return fopen(filename, modes);
}

FILE *mock_fopen(const char *filename, const char *modes)
{
    FILE *fp;

    if (_mock_stdio != nullptr)
    {
        fp = _mock_stdio->fopen(filename, modes);
    }
    else
    {
        fp = delegate_real_fopen(filename, modes);
    }
    
    if (mock_fopen_enable_trace != 0)
    {
        if (fp == NULL)
        {
            printf("  > fopen %s, %c -> NULL\n", filename, *modes);
        }
        else
        {
            printf("  > fopen %s, %c -> %d\n", filename, *modes, fp->_fileno);
        }
    }

    return fp;
}
