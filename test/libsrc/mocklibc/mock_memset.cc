#include <gmock/gmock.h>

#include <mock_string.h>

int mock_memset_enable_trace = 0;

void *delegate_real_memset(void *s, int c, size_t n)
{
    return memset(s, c, n);
}

void *mock_memset(const char *file, const int line, const char *func, void *s, int c, size_t n)
{
    void *result = NULL;

    if (_mock_string != nullptr)
    {
        result = _mock_string->memset(file, line, func, s, c, n);
    }
    else
    {
        result = delegate_real_memset(s, c, n);
    }

    if (mock_memset_enable_trace != 0)
    {
        if (result == NULL)
        {
            printf("  > memset 0x%p, 0x%02x, %ld from %s:%d -> NULL\n", s, c, n, file, line);
        }
        else
        {
            printf("  > memset 0x%p, 0x%02x, %ld from %s:%d -> 0x%p\n", s, c, n, file, line, result);
        }
    }

    return result;
}
