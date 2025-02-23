#include "gtest/gtest.h"

extern "C" int __wrap_main(int , char **);

// -Wl,--wrap=main を利用して main() を wrap した際のエントリーポイント
int __wrap_main(int argc, char **argv) {
  printf("Running main() from %s\n", __FILE__);
  testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
