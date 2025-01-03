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

#include <gmock/gmock.h>

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

#endif // __cplusplus

#endif // _TEST_COM_H_
