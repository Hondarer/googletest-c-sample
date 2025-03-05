#ifndef _MOCK_STDIO_H_
#define _MOCK_STDIO_H_

#include <stdio.h>

#ifdef __cplusplus
extern "C"
{
#endif

    extern int mock_fclose(const char *, const int, const char *, FILE *);
    extern int mock_fflush(const char *, const int, const char *, FILE *);
    extern FILE *mock_fopen(const char *, const int, const char *, const char *, const char *);
    extern int mock_fprintf(const char *, const int, const char *, FILE *, const char *, ...) __attribute__((format(printf, 5, 6)));
    extern int mock_scanf(const char *, const int, const char *, const char *, ...) __attribute__((format(scanf, 4, 5)));

#ifdef __cplusplus
}
#endif

#ifdef _IN_OVERRIDE_HEADER_STDIO_H_

#define fclose(stream) mock_fclose(__FILE__, __LINE__, __func__, stream)
#define fflush(stream) mock_fflush(__FILE__, __LINE__, __func__, stream)
#define fopen(filename, modes) mock_fopen(__FILE__, __LINE__, __func__, filename, modes)
#define fprintf(stream, format, ...) mock_fprintf(__FILE__, __LINE__, __func__, stream, format, ##__VA_ARGS__)
#define scanf(format, ...) mock_scanf(__FILE__, __LINE__, __func__, format, ##__VA_ARGS__)

#else // _IN_OVERRIDE_HEADER_STDIO_H_

#include <gmock/gmock.h>

extern int mock_fclose_enable_trace;
extern int mock_fflush_enable_trace;
extern int mock_fopen_enable_trace;
extern int mock_fprintf_enable_trace;
extern int mock_scanf_enable_trace;

extern int delegate_real_fclose(FILE *);
extern int delegate_real_fflush(FILE *);
extern FILE *delegate_real_fopen(const char *, const char *);
extern int delegate_real_fprintf(FILE *, const char *);
extern int delegate_real_scanf(const char *, va_list) __attribute__((format(scanf, 1, 0)));

class Mock_stdio
{
public:
    MOCK_METHOD(int, access, (const char *, const int, const char *, const char *, int));
    MOCK_METHOD(int, fclose, (const char *, const int, const char *, FILE *));
    MOCK_METHOD(int, fflush, (const char *, const int, const char *, FILE *));
    MOCK_METHOD(FILE *, fopen, (const char *, const int, const char *, const char *, const char *));
    MOCK_METHOD(int, fprintf, (const char *, const int, const char *, FILE *, const char *));
    MOCK_METHOD(int, scanf, (const char *, const int, const char *, const char *, va_list));

    Mock_stdio();
    ~Mock_stdio();
};

extern Mock_stdio *_mock_stdio;

#endif // _IN_OVERRIDE_HEADER_STDIO_H_

#endif // _MOCK_STDIO_H_
