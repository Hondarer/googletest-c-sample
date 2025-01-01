#ifndef _MOCK_STDIO_H_
#define _MOCK_STDIO_H_

#include <stdio.h>
#include <gmock/gmock.h>
#include <mock_stdio_extern.h>

extern int mock_fopen_enable_trace;
extern int mock_fclose_enable_trace;

// fopen のモッククラス
class Mock_fopen
{
public:
    MOCK_METHOD2(fopen, FILE *(const char *, const char *));

    Mock_fopen();
    ~Mock_fopen();

    // 実際の fopen 関数を呼び出すモッククラスの中継メソッド
    FILE *delegate_real_fopen(const char *, const char *);
};

// fclose のモッククラス
class Mock_fclose
{
public:
    MOCK_METHOD1(fclose, int(FILE *));

    Mock_fclose();
    ~Mock_fclose();

    // 実際の fclose 関数を呼び出すモッククラスの中継メソッド
    int delegate_real_fclose(FILE *);
};

#endif // _MOCK_STDIO_H_
