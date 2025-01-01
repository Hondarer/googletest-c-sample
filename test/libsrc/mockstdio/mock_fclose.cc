#include <mock_stdio.h>

using namespace testing;

static Mock_fclose *_mock_fclose = nullptr;

int mock_fclose_enable_trace = 0;

Mock_fclose::Mock_fclose()
{
    ON_CALL(*this, fclose(_))
        .WillByDefault(Invoke(delegate_real_fclose));
    _mock_fclose = this;
}

Mock_fclose::~Mock_fclose()
{
    _mock_fclose = nullptr;
}

int delegate_real_fclose(FILE *fp)
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
        rtc = delegate_real_fclose(fp);
    }
    if (mock_fclose_enable_trace != 0)
    {
        printf("  > fclose %d -> %d\n", fileno, rtc);
    }

    return rtc;
}
