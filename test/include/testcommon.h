#ifndef _TESTCOMMON_H_
#define _TESTCOMMON_H_

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

AssertionResult FileExists(const string &);

AssertionResult FileExists(const string &file_path)
{
    struct stat buffer;
    if (stat(file_path.c_str(), &buffer) == 0)
    {
        return AssertionSuccess();
    }
    else
    {
        return AssertionFailure() << "File " << file_path << " does not exist.";
    }
}

#define EXPECT_FILE_EXISTS(file_path) \
    EXPECT_TRUE(FileExists(file_path))

AssertionResult FileNotExists(const string &);

AssertionResult FileNotExists(const string &file_path)
{
    struct stat buffer;
    if (stat(file_path.c_str(), &buffer) != 0)
    {
        return AssertionSuccess();
    }
    else
    {
        return AssertionFailure() << "File " << file_path << " does exist.";
    }
}

#define EXPECT_FILE_NOT_EXISTS(file_path) \
    EXPECT_TRUE(FileNotExists(file_path))

AssertionResult FileContains(const string &, const string &);

AssertionResult FileContains(const string &file_path, const string &expected_content)
{
    ifstream file(file_path);
    if (!file.is_open())
    {
        return AssertionFailure() << "File " << file_path << " does not exist.";
    }

    string line;
    while (getline(file, line))
    {
        if (line.find(expected_content) != string::npos)
        {
            cout << "String \"" << expected_content << "\" found in file " << file_path << ", \"" << line << "\"" << endl;
            return AssertionSuccess();
        }
    }

    return AssertionFailure() << "String \"" << expected_content << "\" not found in file " << file_path;
}

#define EXPECT_FILE_CONTAINS(file_path, expected_content) \
    EXPECT_TRUE(FileContains(file_path, expected_content))

#define EXPECT_STR_EQ(expected, actual) \
    EXPECT_PRED_FORMAT2(internal::CmpHelperSTREQ, expected, actual)

#endif // __cplusplus

#endif // _TESTCOMMON_H_
