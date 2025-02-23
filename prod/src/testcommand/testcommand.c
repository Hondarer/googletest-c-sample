#include <stdio.h>

extern int samplefunc(void);

int main(int argc, char** argv)
{
    (void)argc;
    (void)argv;
    return samplefunc();
}

int samplefunc()
{
    return 123;
}
