#pragma once
namespace spalm_dispatch {
enum class Backend { Internal, MklDense, MklSparse };
inline Backend select(bool force_dense, bool force_sparse, bool fallback,
                      bool auto_dense, bool auto_sparse) {
  // Explicit methods take precedence over every automatic cost heuristic.
  if (force_dense) return Backend::MklDense;
  if (force_sparse) return Backend::MklSparse;
  if (fallback && auto_dense) return Backend::MklDense;
  if (fallback && auto_sparse) return Backend::MklSparse;
  return Backend::Internal;
}
}
