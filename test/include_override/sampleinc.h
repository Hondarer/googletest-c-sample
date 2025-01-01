#ifndef _SAMPLE_INC_H_
/* 本物の include で define されるため、ここでは define しない */
/* #define _SAMPLE_INC_H_ */

#include <stdio.h>
#include <mock_stdio_extern.h>

#ifdef __cplusplus
extern "C"
{
#endif

/* 本物を include */
#include "../../prod/include/sampleinc.h"

/* テスト向けの内容改変の例 */
#undef HELLO_MSG
#define HELLO_MSG "Hello world, override."

/* モックへのすげ替え */
#define fopen(filename, modes) mock_fopen(filename, modes)
#define fclose(fp) mock_fclose(fp)

#ifdef __cplusplus
}
#endif

#endif // _SAMPLE_INC_H_s