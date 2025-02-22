// このソースはテスト対象の末尾に結合されるので
// static メンバーへのアクセサーを記載することで
// テストプログラムから static メンバーにアクセスできるようになる
#ifndef _IN_TEST_FRAMEWORK_
#include "samplestatic.c"
#endif // _IN_TEST_FRAMEWORK_

#include "samplestatic.inject.h"

void set_static_int(int set_value)
{
    static_int = set_value;
}
