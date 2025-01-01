#ifndef _MOCK_STDIO_H_
#define _MOCK_STDIO_H_

#include <stdio.h>

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wpadded"
#include <gmock/gmock.h>
#pragma GCC diagnostic pop

#include <mock_stdio_extern.h>

extern int mock_fclose_enable_trace;
extern int mock_fflush_enable_trace;
extern int mock_fopen_enable_trace;
extern int mock_fprintf_enable_trace;

// fclose のモッククラス
class Mock_fclose
{
public:
    MOCK_METHOD1(fclose, int(FILE *));

    Mock_fclose();
    ~Mock_fclose();
};
extern int delegate_real_fclose(FILE *);

// fflush のモッククラス
class Mock_fflush
{
public:
    MOCK_METHOD1(fflush, int(FILE *));

    Mock_fflush();
    ~Mock_fflush();
};
extern int delegate_real_fflush(FILE *);

// fopen のモッククラス
class Mock_fopen
{
public:
    MOCK_METHOD2(fopen, FILE *(const char *, const char *));

    Mock_fopen();
    ~Mock_fopen();
};
extern FILE *delegate_real_fopen(const char *, const char *);

// fprintf のモッククラス
class Mock_fprintf
{
public:
    MOCK_METHOD2(fprintf, int(FILE *, const char *));

    Mock_fprintf();
    ~Mock_fprintf();
};
extern int delegate_real_fprintf(FILE *, const char *);

#endif // _MOCK_STDIO_H_
