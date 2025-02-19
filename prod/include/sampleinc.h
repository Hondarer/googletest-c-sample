#ifndef _SAMPLE_INC_H_
#define _SAMPLE_INC_H_

#ifdef __cplusplus
extern "C"
{
#endif

#define LOG_WARN (3)
#define LOG_INFO (2)
#define LOG_VERBOSE (1)

#define HELLO_MSG "Hello world."

    extern int samplelogger(const int, const char *fmt, ...) __attribute__((format(printf, 2, 3)));
    extern int samplefunc(const int, const int);
    extern int samplefunc2(const int, const int);

#ifdef __cplusplus
}
#endif

#endif // _SAMPLE_INC_H_