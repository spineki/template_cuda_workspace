#include <benchmark/benchmark.h>

// Entrypoint to trigger all benches in this folder
// Normally, we would link against "benchmark_main" (-lbenchmark_main) to get an automatic main as it is done for google tests. (and thus avoid having this placeholder file)
// This doesn't seem to work (see https://github.com/google/benchmark/issues/1070) anymore.
// So please, fix this or keep this file as simple as possible

// If you want to add new benches, please create a bench_<name>.cpp file in this folder.
// Prefix your bench functions with BM_ (benchmark).
// (see https://github.com/google/benchmark/blob/main/docs/user_guide.md)
// Good-to-know: You can create multiple benches in a single file, as you would do for tests

BENCHMARK_MAIN();
