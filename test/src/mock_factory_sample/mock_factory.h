#ifndef _MOCK_FACTORY_H_
#define _MOCK_FACTORY_H_
#include <mock_factory_head.h>

// ---------------------------------------------------------------------------

// mock 対象の関数宣言が含まれているヘッダを include
#include "testfunc.h"

//
// 作成したいモックの宣言
//
// MOCK_C_METHOD(戻り値の型, 関数名, 引数..., デフォルトの戻り値を表すラムダ式)
// MOCK_C_METHOD(void, 関数名, 引数...)
//   ※ 戻り値の型が void の場合のみ、デフォルトの戻り値を表すラムダ式を指定しない
//   ※ Return() を用いて、戻り値を表すラムダ式を簡易的に記述可能
//

// func1 の自動宣言 (Mock_func1 クラスの宣言も自動生成される)
MOCK_C_METHOD(int, func1, int, int, [](int a, int b)
              { return a + b; });

// func2 の自動宣言
MOCK_C_METHOD(int, func2, int, int, Return(-1));

// func3 の自動宣言
MOCK_C_METHOD(void *, func3, int, int, Return((void *)NULL));

// func4 の自動宣言
MOCK_C_METHOD(void, func4, int, int);

// ---------------------------------------------------------------------------

#include <mock_factory_tail.h>
#endif // _MOCK_FACTORY_H_
