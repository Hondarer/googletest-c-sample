// スタックトレース取得のサンプルプログラム
// Linux版: bfdライブラリを使用
// Windows版: DbgHelpライブラリを使用
// 最終的にはテストライブラリへ組み込む

// Linux:   gcc -g -o fixed_trace fixed_trace.c -lbfd -ldl
// Windows: cl /Zi fixed_trace.c dbghelp.lib

#include <stdio.h>
#include <stdlib.h>

#ifdef _WIN32
// Windows版
#include <windows.h>
#include <dbghelp.h>
#else
// Linux版
#include <execinfo.h>
#include <bfd.h>
#include <dlfcn.h>
#include <unistd.h>
#include <linux/limits.h>
#endif

#define STACK_SIZE 100

// グローバル変数
#ifdef _WIN32
static HANDLE g_process = NULL;
static int g_initialized = 0;
#else
bfd *global_bfd = NULL;
asymbol **global_syms = NULL;
unsigned int global_storage_needed = 0;
#endif

#ifdef _WIN32
// ========== Windows版実装 ==========

// 終了時のクリーンアップ
void cleanup()
{
    if (g_initialized)
    {
        SymCleanup(g_process);
    }
}

// 初期化処理
void initialize_dbghelp()
{
    g_process = GetCurrentProcess();

    SymSetOptions(SYMOPT_LOAD_LINES | SYMOPT_UNDNAME);

    if (!SymInitialize(g_process, NULL, TRUE))
    {
        fprintf(stderr, "SymInitialize failed: %lu\n", GetLastError());
        exit(EXIT_FAILURE);
    }

    g_initialized = 1;
    atexit(cleanup);
}

void find_line_info(void *addr)
{
    // シンボル情報構造体 (動的に確保)
    SYMBOL_INFO *symbol = (SYMBOL_INFO *)calloc(sizeof(SYMBOL_INFO) + 256, 1);
    if (!symbol)
    {
        return;
    }
    symbol->MaxNameLen = 255;
    symbol->SizeOfStruct = sizeof(SYMBOL_INFO);

    // ライン情報構造体
    IMAGEHLP_LINE64 line;
    line.SizeOfStruct = sizeof(IMAGEHLP_LINE64);

    DWORD64 address = (DWORD64)addr;
    DWORD displacement = 0;

    // 関数名を取得
    const char *functionname = "unknown";
    if (SymFromAddr(g_process, address, NULL, symbol))
    {
        functionname = symbol->Name;
    }

    // ファイル名と行番号を取得
    const char *filename = "unknown";
    unsigned int line_num = 0;
    if (SymGetLineFromAddr64(g_process, address, &displacement, &line))
    {
        filename = line.FileName;
        line_num = line.LineNumber;
    }

    printf("  File: %s, Line: %u, Function: %s\n",
           filename, line_num, functionname);

    free(symbol);
}

void print_stack_trace()
{
    if (!g_initialized)
    {
        initialize_dbghelp();
    }

    void *stack[STACK_SIZE];
    WORD frames = CaptureStackBackTrace(0, STACK_SIZE, stack, NULL);

    printf("Stack trace (most recent call first):\n");
    for (WORD i = 0; i < frames; i++)
    {
        find_line_info(stack[i]);
    }
}

#else
// ========== Linux版実装 ==========

// 実行ファイルのパスを取得
void get_executable_path(char *exec_path, size_t size)
{
    ssize_t len = readlink("/proc/self/exe", exec_path, size - 1);
    if (len == -1)
    {
        perror("readlink");
        exit(EXIT_FAILURE);
    }
    exec_path[len] = '\0'; // 終端文字を追加
}

// 終了時のクリーンアップ
void cleanup()
{
    if (global_syms)
    {
        free(global_syms);
    }
    if (global_bfd)
    {
        bfd_close(global_bfd);
    }
}

// 初期化処理 (初回のみ呼び出される)
void initialize_bfd(const char *exec_file)
{
    bfd_init();
    global_bfd = bfd_openr(exec_file, NULL);
    if (!global_bfd)
    {
        fprintf(stderr, "Failed to open binary file: %s\n", exec_file);
        exit(EXIT_FAILURE);
    }

    if (!bfd_check_format(global_bfd, bfd_object))
    {
        fprintf(stderr, "Invalid binary format.\n");
        bfd_close(global_bfd);
        exit(EXIT_FAILURE);
    }

    global_storage_needed = bfd_get_symtab_upper_bound(global_bfd);
    if (global_storage_needed == 0)
    {
        fprintf(stderr, "No symbol table available.\n");
        bfd_close(global_bfd);
        exit(EXIT_FAILURE);
    }

    global_syms = (asymbol **)malloc(global_storage_needed);
    if (bfd_canonicalize_symtab(global_bfd, global_syms) <= 0)
    {
        fprintf(stderr, "Failed to read symbol table.\n");
        free(global_syms);
        bfd_close(global_bfd);
        exit(EXIT_FAILURE);
    }

    // クリーンアップ処理を登録
    atexit(cleanup);
}

void find_line_info(void *addr)
{
    asection *section = global_bfd->sections;
    for (; section != NULL; section = section->next)
    {
        if ((bfd_get_section_flags(global_bfd, section) & SEC_ALLOC) == 0)
        {
            continue;
        }

        bfd_vma vma = bfd_get_section_vma(global_bfd, section);
        if ((bfd_vma)addr < vma || (bfd_vma)addr >= vma + bfd_section_size(global_bfd, section))
        {
            continue;
        }

        const char *filename;
        const char *functionname;
        unsigned int line;
        if (bfd_find_nearest_line(global_bfd, section, global_syms, (bfd_vma)addr - vma, &filename, &functionname, &line))
        {
            // printf("  Address: %p, Function: %s, File: %s, Line: %u\n",
            //        addr,
            //        functionname ? functionname : "unknown",
            //        filename ? filename : "unknown",
            //        line);
            printf("  File: %s, Line: %u, Function: %s\n",
                   filename ? filename : "unknown",
                   line,
                   functionname ? functionname : "unknown");
            break;
        }
    }
}

void print_stack_trace()
{
    char exec_path[PATH_MAX];
    static int initialized = 0;

    if (!initialized)
    {
        get_executable_path(exec_path, sizeof(exec_path));
        initialize_bfd(exec_path);
        initialized = 1;
    }

    void *stack[STACK_SIZE];
    int size = backtrace(stack, STACK_SIZE);

    printf("Stack trace (most recent call first):\n");
    for (int i = 0; i < size; i++)
    {
        find_line_info(stack[i]);
    }
}

#endif // _WIN32

// ========== 共通テストコード ==========

void func3()
{
    print_stack_trace();
}

void func2()
{
    func3();
}

void func1()
{
    func2();
}

int main()
{
    func1();
    return 0;
}
