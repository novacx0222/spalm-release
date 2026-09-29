# GNU OpenMP build for SPALM and its MKL baseline library.
# Usage: make -B spalm OPT_LEVEL=-O0 MKL_ROOT=/opt/intel/oneapi/mkl/2026.1
.DEFAULT_GOAL := spalm
CXX = g++
MKL_ROOT ?= $(ONEAPI_ROOT)/mkl/latest
MKL_LIBDIR ?= $(MKL_ROOT)/lib
OPT_LEVEL ?= -O3
SPALM_CXXFLAGS = -fPIC -mavx -march=native -std=c++20 -g3 $(OPT_LEVEL) -fno-omit-frame-pointer -fopenmp
SPALM_INCLUDES = -Iinclude -I$(MKL_ROOT)/include
SPALM_MKL_LINK = -L$(MKL_LIBDIR) -Wl,-rpath,$(MKL_LIBDIR) -Wl,--no-as-needed -lmkl_intel_lp64 -lmkl_gnu_thread -lmkl_core -lgomp -lpthread -lm -ldl
SRC_DIR = src
CPU_SRC_DIR = $(SRC_DIR)/cpu
BIN_DIR = bin
SPALM_OBJS = $(BIN_DIR)/spalm.o $(BIN_DIR)/sparse_sparse_matmul.o $(BIN_DIR)/dense_dense_matmul.o $(BIN_DIR)/slice_decision.o $(BIN_DIR)/kernel.o
.PHONY: spalm baseline debug clean
$(BIN_DIR):
	mkdir -p $(BIN_DIR)
spalm: $(BIN_DIR)/spalm.so
baseline: $(BIN_DIR)/run_baseline.so
$(BIN_DIR)/spalm.so: $(BIN_DIR)/run_baseline.so $(SPALM_OBJS) | $(BIN_DIR)
	$(CXX) -shared -fopenmp $(LDFLAGS) $(SPALM_OBJS) $(SPALM_MKL_LINK) -o $@
$(BIN_DIR)/run_baseline.so: $(SRC_DIR)/run_baseline.cpp | $(BIN_DIR)
	$(CXX) $(CPPFLAGS) $(SPALM_CXXFLAGS) $(SPALM_INCLUDES) -shared $< $(LDFLAGS) $(SPALM_MKL_LINK) -o $@
$(BIN_DIR)/spalm.o: $(CPU_SRC_DIR)/spalm.cpp include/ss_mat.h | $(BIN_DIR)
	$(CXX) $(CPPFLAGS) $(SPALM_CXXFLAGS) $(SPALM_INCLUDES) -c $< -o $@
$(BIN_DIR)/sparse_sparse_matmul.o: $(CPU_SRC_DIR)/sparse_sparse_matmul.cpp include/ss_mat.h | $(BIN_DIR)
	$(CXX) $(CPPFLAGS) $(SPALM_CXXFLAGS) $(SPALM_INCLUDES) -c $< -o $@
$(BIN_DIR)/dense_dense_matmul.o: $(CPU_SRC_DIR)/dense_dense_matmul.cpp include/ss_mat.h | $(BIN_DIR)
	$(CXX) $(CPPFLAGS) $(SPALM_CXXFLAGS) $(SPALM_INCLUDES) -c $< -o $@
$(BIN_DIR)/slice_decision.o: $(SRC_DIR)/slice_decision.cpp include/slice_decision.h | $(BIN_DIR)
	$(CXX) $(CPPFLAGS) $(SPALM_CXXFLAGS) $(SPALM_INCLUDES) -c $< -o $@
$(BIN_DIR)/kernel.o: $(CPU_SRC_DIR)/kernel.cpp include/ss_mat.h | $(BIN_DIR)
	$(CXX) $(CPPFLAGS) $(SPALM_CXXFLAGS) $(SPALM_INCLUDES) -c $< -o $@
debug:
	$(MAKE) -f $(firstword $(MAKEFILE_LIST)) -B spalm OPT_LEVEL=-O0 MKL_ROOT="$(MKL_ROOT)" MKL_LIBDIR="$(MKL_LIBDIR)"
clean:
	rm -f $(SPALM_OBJS) $(BIN_DIR)/spalm.so $(BIN_DIR)/run_baseline.so
