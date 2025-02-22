// テスト対象ソースファイルの注入用追加ソースのヘッダ
// このヘッダをテストプログラムが参照することで
// テスト対象ソースの static メンバにアクセスできる
#ifndef _SAMPLESTATIC_INJECT_H
#define _SAMPLESTATIC_INJECT_H

#ifdef __cplusplus
extern "C"
{
#endif

    extern void set_static_int(int);

#ifdef __cplusplus
}
#endif

#endif // _SAMPLESTATIC_INJECT_H
