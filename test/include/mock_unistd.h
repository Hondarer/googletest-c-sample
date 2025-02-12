#ifndef _MOCK_UNISTD_H_
#define _MOCK_UNISTD_H_

#include <unistd.h>

#ifdef __cplusplus
extern "C"
{
#endif

    extern int mock_access(const char *, int);

#ifdef __cplusplus
}
#endif

#ifdef _IN_OVERRIDE_HEADER_UNISTD_H_

#define access(path, amode) mock_access(path, amode)

#else // _IN_OVERRIDE_HEADER_UNISTD_H_

#include <gmock/gmock.h>

extern int mock_access_enable_trace;

extern int delegate_real_access(const char *, int);

class Mock_unistd
{
public:
    MOCK_METHOD(int, access, (const char *, int));

    Mock_unistd();
    ~Mock_unistd();
};

extern Mock_unistd *_mock_unistd;

#endif // _IN_OVERRIDE_HEADER_UNISTD_H_

#endif // _MOCK_UNISTD_H_
