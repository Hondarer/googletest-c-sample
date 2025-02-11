#include <gmock/gmock.h>

#include <mock_string.h>

int mock_memset_enable_trace = 0;

void *delegate_real_memset(void *s, int c, size_t n)
{
    return memset(s, c, n);
}

void *mock_memset(void *s, int c, size_t n)
{
    void *result = NULL;

    if (_mock_string != nullptr)
    {
        result = _mock_string->memset(s, c, n);
    }
    else
    {
        result = delegate_real_memset(s, c, n);
    }

    if (mock_memset_enable_trace != 0)
    {
        if (result == NULL)
        {
            printf("  > memset 0x%p, 0x%02x, %ld -> NULL\n", s, c, n);
        }
        else
        {
            printf("  > memset 0x%p, 0x%02x, %ld -> 0x%p\n", s, c, n, result);
        }
    }

    return result;
}
