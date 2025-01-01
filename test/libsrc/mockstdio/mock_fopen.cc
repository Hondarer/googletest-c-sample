#include <mock_stdio.h>

using namespace testing;

static FILE *real_fopen(const char *, const char *);

static Mock_fopen *_mock_fopen = nullptr;

int mock_fopen_enable_trace = 0;

Mock_fopen::Mock_fopen()
{
    ON_CALL(*this, fopen(_, _))
        .WillByDefault(Invoke([this](const char *filename, const char *modes)
                              { return delegate_real_fopen(filename, modes); }));
    _mock_fopen = this;
}

Mock_fopen::~Mock_fopen()
{
    _mock_fopen = nullptr;
}

FILE *Mock_fopen::delegate_real_fopen(const char *filename, const char *modes)
{
    return real_fopen(filename, modes);
}

static FILE *real_fopen(const char *filename, const char *modes)
{
    return fopen(filename, modes);
}

FILE *mock_fopen(const char *filename, const char *modes)
{
    FILE *fp;
    if (_mock_fopen != nullptr)
    {
        fp = _mock_fopen->fopen(filename, modes);
    }
    else
    {
        fp = real_fopen(filename, modes);
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
