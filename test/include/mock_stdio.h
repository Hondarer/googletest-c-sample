#ifndef _MOCK_STDIO_H_
#define _MOCK_STDIO_H_

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

#ifndef GOOGLEMOCK_INCLUDE_GMOCK_GMOCK_H_

#define fclose(stream) mock_fclose(stream)
#define fflush(stream) mock_fflush(stream)
#define fopen(filename, modes) mock_fopen(filename, modes)
#define fprintf(stream, format, ...) mock_fprintf(stream, format, ##__VA_ARGS__)

#else

#include <gmock/gmock.h>

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

#endif // GOOGLEMOCK_INCLUDE_GMOCK_GMOCK_H_

#endif // _MOCK_STDIO_H_
