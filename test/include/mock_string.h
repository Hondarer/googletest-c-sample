#ifndef _MOCK_STRING_H_
#define _MOCK_STRING_H_

#include <string.h>

#ifdef __cplusplus
extern "C"
{
#endif

    extern void *mock_memset(void *, int, size_t);

#ifdef __cplusplus  
}
#endif

#ifdef _IN_OVERRIDE_HEADER_STRING_H_

#define memset(s, c, n) mock_memset(s, c, n)

#else // _IN_OVERRIDE_HEADER_STRING_H_

#include <gmock/gmock.h>

extern int mock_memset_enable_trace;

extern void *delegate_real_memset(void *, int, size_t);

class Mock_string
{
public:
MOCK_METHOD(void *, memset, (void *, int, size_t));

    Mock_string();
    ~Mock_string();
};

extern Mock_string *_mock_string;

#endif // _IN_OVERRIDE_HEADER_STRING_H_

#endif // _MOCK_STRING_H_
