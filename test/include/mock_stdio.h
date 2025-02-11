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

#ifdef _IN_OVERRIDE_HEADER_STDIO_H_

#define fclose(stream) mock_fclose(stream)
#define fflush(stream) mock_fflush(stream)
#define fopen(filename, modes) mock_fopen(filename, modes)
#define fprintf(stream, format, ...) mock_fprintf(stream, format, ##__VA_ARGS__)

#else // _IN_OVERRIDE_HEADER_STDIO_H_

#include <gmock/gmock.h>

extern int mock_fclose_enable_trace;
extern int mock_fflush_enable_trace;
extern int mock_fopen_enable_trace;
extern int mock_fprintf_enable_trace;

extern int delegate_real_access(const char *, int);
extern int delegate_real_fclose(FILE *);
extern int delegate_real_fflush(FILE *);
extern FILE *delegate_real_fopen(const char *, const char *);
extern int delegate_real_fprintf(FILE *, const char *);

class Mock_stdio
{
public:
    MOCK_METHOD(int, access, (const char *, int));
    MOCK_METHOD(int, fclose, (FILE *));
    MOCK_METHOD(int, fflush, (FILE *));
    MOCK_METHOD(FILE *, fopen, (const char *, const char *));
    MOCK_METHOD(int, fprintf, (FILE *, const char *));

    Mock_stdio();
    ~Mock_stdio();
};

extern Mock_stdio *_mock_stdio;

#endif // _IN_OVERRIDE_HEADER_STDIO_H_

#endif // _MOCK_STDIO_H_
