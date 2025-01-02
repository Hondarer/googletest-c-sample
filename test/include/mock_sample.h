#ifndef _MOCK_SAMPLE_H_
#define _MOCK_SAMPLE_H_

#include <stdio.h>
#include <gmock/gmock.h>

extern int mock_samplelogger_enable_trace;

// samplelogger のモッククラス
class Mock_samplelogger
{
public:
    MOCK_METHOD(int, samplelogger, (int, const char *));

    Mock_samplelogger();
    ~Mock_samplelogger();
};

#endif // _MOCK_SAMPLE_H_
