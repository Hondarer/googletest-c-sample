#include "testfunc.h"

int testfunc_entry(int kind)
{
    int rtc = 0;

    switch (kind)
    {
    case 1:
        rtc = func1(1, 2);
        break;
    case 2:
        rtc = func2(1, 2);
        break;
    case 3:
        func3(1, 2);
        break;
    case 4:
        func4(1, 2);
        break;
    default:
        break;
    }

    return rtc;
}
