#include <gmock/gmock.h>

#include <mock_stdio.h>

using namespace testing;

Mock_stdio *_mock_stdio = nullptr;

// avoid -Wsuggest-attribute=format
int delegate_real_scanf_with_unused(Unused, Unused, Unused, const char *format, va_list arg_ptr) __attribute__((format(scanf, 4, 0)));
int delegate_real_scanf_with_unused(Unused, Unused, Unused, const char *format, va_list arg_ptr)
{
    return delegate_real_scanf(format, arg_ptr);
}

Mock_stdio::Mock_stdio()
{
    ON_CALL(*this, fclose(_, _, _, _))
        .WillByDefault(Invoke([](Unused, Unused, Unused, FILE *fp)
                              { return delegate_real_fclose(fp); }));

    ON_CALL(*this, fflush(_, _, _, _))
        .WillByDefault(Invoke([](Unused, Unused, Unused, FILE *fp)
                              { return delegate_real_fflush(fp); }));

    ON_CALL(*this, fopen(_, _, _, _, _))
        .WillByDefault(Invoke([](Unused, Unused, Unused, const char *filename, const char *modes)
                              { return delegate_real_fopen(filename, modes); }));

    ON_CALL(*this, fprintf(_, _, _, _, _))
        .WillByDefault(Invoke([](Unused, Unused, Unused, FILE *stream, const char *str)
                              { return delegate_real_fprintf(stream, str); }));

    ON_CALL(*this, vfprintf(_, _, _, _, _))
        .WillByDefault(Invoke([](Unused, Unused, Unused, FILE *stream, const char *str)
                              { return delegate_real_vfprintf(stream, str); }));

    ON_CALL(*this, scanf(_, _, _, _, _))
        .WillByDefault(Invoke(delegate_real_scanf_with_unused));

    _mock_stdio = this;
}

Mock_stdio::~Mock_stdio()
{
    _mock_stdio = nullptr;
}
