#ifndef _MOCK_SAMPLE_H_
#define _MOCK_SAMPLE_H_

#include <stdio.h>
#include <gmock/gmock.h>

class Mock_sample
{
public:
    MOCK_METHOD(int, samplelogger, (int, const char *));

    Mock_sample();
    ~Mock_sample();
};

extern Mock_sample *_mock_sample;

#endif // _MOCK_SAMPLE_H_
