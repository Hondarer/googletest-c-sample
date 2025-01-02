#ifndef _SAMPLE_INC_H_
/* 本物の include で define されるため、ここでは define しない */
/* #define _SAMPLE_INC_H_ */

/* 本物を include */
#include "../../prod/include/sampleinc.h"

#include <mock_stdio.h>

#ifndef GOOGLEMOCK_INCLUDE_GMOCK_GMOCK_H_

/* テスト向けの内容改変の例 */
#undef HELLO_MSG
#define HELLO_MSG "Hello world, override."

#endif // GOOGLEMOCK_INCLUDE_GMOCK_GMOCK_H_

#endif // _SAMPLE_INC_H_