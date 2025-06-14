#ifndef _TEST_FUNC_H_
#define _TEST_FUNC_H_

#ifdef __cplusplus
extern "C"
{
#endif

// テスト対象の関数
extern int testfunc_entry(int kind);

// 以下の 4 関数は外部関数であり、テストのためにモックを作成する必要がある
// このモック生成を mock_factory.h, mock_factory.cc で行う
extern int func1(int para1, int para2);
extern int func2(int para1, int para2);
extern void* func3(int para1, int para2);
extern void func4(int para1, int para2);

#ifdef __cplusplus
}
#endif

#endif // _TEST_FUNC_H_
