#ifndef _MOCK_SYS_STAT_H_
#define _MOCK_SYS_STAT_H_

#include <sys/stat.h>

#ifdef __cplusplus
extern "C"
{
#endif

extern int mock_stat(const char *, struct stat *);

#ifdef __cplusplus
}
#endif

#ifdef _IN_OVERRIDE_HEADER_STAT_H_

#define stat(path, buf) mock_stat(path, buf)

#else // _IN_OVERRIDE_HEADER_STAT_H_

#include <gmock/gmock.h>

extern int mock_stat_enable_trace;

extern int delegate_real_stat(const char *, struct stat *);

class Mock_sys_stat
{
public:
MOCK_METHOD(int, stat, (const char *, struct stat *));

    Mock_sys_stat();
    ~Mock_sys_stat();
};

extern Mock_sys_stat *_mock_sys_stat;

#endif // _IN_OVERRIDE_HEADER_STAT_H_

#endif // _MOCK_SYS_STAT_H_
