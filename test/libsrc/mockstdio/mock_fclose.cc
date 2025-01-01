#include <mock_stdio.h>

using namespace testing;

static int real_fclose(FILE*);

static Mock_fclose *_mock_fclose = nullptr;

int mock_fclose_enable_trace = 0;

Mock_fclose::Mock_fclose()
{
    ON_CALL(*this, fclose(_))
        .WillByDefault(Invoke([this](FILE *fp)
                              { return delegate_real_fclose(fp); }));
    _mock_fclose = this;
}

Mock_fclose::~Mock_fclose()
{
    _mock_fclose = nullptr;
}

int Mock_fclose::delegate_real_fclose(FILE *fp)
{
    return real_fclose(fp);
}

static int real_fclose(FILE *fp)
{
    return fclose(fp);
}

int mock_fclose(FILE *fp)
{
    int fileno = fp->_fileno; // fclose 内にて初期化されるため、退避
    int rtc;
    if (_mock_fclose != nullptr)
    {
        rtc = _mock_fclose->fclose(fp);
    }
    else
    {
        rtc = real_fclose(fp);
    }
    if (mock_fclose_enable_trace != 0)
    {
        printf("  > fclose %d -> %d\n", fileno, rtc);
    }

    return rtc;
}
