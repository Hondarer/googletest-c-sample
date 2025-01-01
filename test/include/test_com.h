#ifndef _TEST_COM_H_
#define _TEST_COM_H_

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

#ifdef __cplusplus
extern "C"
{
#endif

    extern char *allocprintf(const char *, ...) __attribute__((format(printf, 1, 2)));
    extern char *allocvprintf(const char *, va_list) __attribute__((format(printf, 1, 0)));

#ifdef __cplusplus
}
#endif

#ifdef __cplusplus

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wpadded"
#include <gmock/gmock.h>
#pragma GCC diagnostic pop

#include <fstream>
#include <iostream>

using namespace std;
using namespace testing;

extern AssertionResult FileExists(const string &);

#define EXPECT_FILE_EXISTS(file_path) \
    EXPECT_TRUE(FileExists(file_path))

extern AssertionResult FileNotExists(const string &);

#define EXPECT_FILE_NOT_EXISTS(file_path) \
    EXPECT_TRUE(FileNotExists(file_path))

extern AssertionResult FileContains(const string &, const string &);

#define EXPECT_FILE_CONTAINS(file_path, expected_content) \
    EXPECT_TRUE(FileContains(file_path, expected_content))

#define EXPECT_STR_EQ(expected, actual) \
    EXPECT_PRED_FORMAT2(internal::CmpHelperSTREQ, expected, actual)

#endif // __cplusplus

#endif // _TEST_COM_H_
