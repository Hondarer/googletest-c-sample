#ifndef _STDLIB_H
/* 本物の include で define されるため、ここでは define しない */
/* #define _STDLIB_H */

/* 本物を include */
#include "/usr/include/stdlib.h"

/* モックにすげ替え */
#define _IN_OVERRIDE_HEADER_STDLIB_H_
#include <mock_stdlib.h>
#undef _IN_OVERRIDE_HEADER_STDLIB_H_

#endif // _STDLIB_H