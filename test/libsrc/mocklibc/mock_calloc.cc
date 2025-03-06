#include <gmock/gmock.h>

#include <mock_stdlib.h>

int mock_calloc_enable_trace = 0;

void *delegate_real_calloc(size_t __nmemb, size_t __size)
{
    return calloc(__nmemb, __size);
}

void *mock_calloc(const char *file, const int line, const char *func, size_t __nmemb, size_t __size)
{
    void *result = NULL;

    if (_mock_stdlib != nullptr)
    {
        result = _mock_stdlib->calloc(file, line, func, __nmemb, __size);
    }
    else
    {
        result = delegate_real_calloc(__nmemb, __size);
    }

    if (mock_calloc_enable_trace != 0)
    {
        // TODO:
    }

    return result;
}
