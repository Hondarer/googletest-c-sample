#ifndef _MOCK_STDIO_EXTERN_H_
#define _MOCK_STDIO_EXTERN_H_

#include <stdio.h>

#ifdef __cplusplus
extern "C"
{
#endif

    extern FILE *mock_fopen(const char *, const char *);
    extern int mock_fclose(FILE *fp);

#ifdef __cplusplus
}
#endif

#endif // _MOCK_STDIO_EXTERN_H_
