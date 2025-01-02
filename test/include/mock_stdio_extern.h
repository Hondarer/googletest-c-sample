#ifndef _MOCK_STDIO_EXTERN_H_
#define _MOCK_STDIO_EXTERN_H_

#include <stdio.h>

#ifdef __cplusplus
extern "C"
{
#endif

    extern int mock_fclose(FILE *);
    extern int mock_fflush(FILE *);
    extern FILE *mock_fopen(const char *, const char *);
    extern int mock_fprintf(FILE *, const char *, ...) __attribute__((format(printf, 2, 3)));

#ifdef __cplusplus
}
#endif

#endif // _MOCK_STDIO_EXTERN_H_
