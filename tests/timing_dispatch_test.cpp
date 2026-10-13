#include "method_dispatch.h"
#include "util.h"
#include <cassert>
#include <cmath>
int main() {
  using spalm_dispatch::Backend;
  using spalm_dispatch::select;
  for (bool fallback : {false, true}) {
    for (bool dense : {false, true}) {
      for (bool sparse : {false, true}) {
        assert(select(false, true, fallback, dense, sparse) == Backend::MklSparse);
        assert(select(true, false, fallback, dense, sparse) == Backend::MklDense);
        auto expected = !fallback ? Backend::Internal : dense ? Backend::MklDense :
                        sparse ? Backend::MklSparse : Backend::Internal;
        assert(select(false, false, fallback, dense, sparse) == expected);
      }
    }
  }
  float seconds = print_time("[test-duration]", std::chrono::nanoseconds(1234567));
  assert(std::abs(seconds - 0.001234567f) < 1e-9f);
  print_time("[test-zero]", std::chrono::nanoseconds(0));
  assert(print_time("[test-silent]", std::chrono::milliseconds(5), false) == 0.005f);
}
