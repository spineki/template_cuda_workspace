#####################################################################################
## CUDA + OpenMP Matrix product lab
## Makefile by S. Vialle, November 2022
## heavily edited, inspired by
## https://api.csswg.org/bikeshed/?force=1&url=https://raw.githubusercontent.com/vector-of-bool/pitchfork/develop/data/spec.bs#tld.build
## https://stackoverflow.com/questions/30573481/how-to-write-a-makefile-with-separate-source-and-header-directories
## https://www.gnu.org/software/make/manual/make.html#Static-Pattern
## https://stackoverflow.com/questions/10276202/exclude-source-file-in-compilation-using-makefile
####################################################################################y#

# Compilers
CPU_CC := g++
GPU_CC := /usr/local/cuda/bin/nvcc

#CUDA_TARGET_FLAGS = -arch=sm_61      #GTX 1080 on Cameron cluster
#CUDA_TARGET_FLAGS = -arch=sm_75      #RTX 2080-Ti on Tx cluster

# Compiler flags
CXX_FLAGS := -std=c++2a  -fopenmp -Wall
#TODO Add a flag to switch from debug to release mode
# uncomment this if you want to have debug symbols (required for vscode debugger)
# CXX_FLAGS += -g
# uncomment this if you want optimizations
CXX_FLAGS += -Ofast
# CPU_CXX_FLAGS += -DDP # uncomment to use double precision
CXX_TESTS_FLAGS := -pthread
CXX_BENCHES_FLAGS := -pthread
CUDA_CXX_FLAGS := -O3 $(CUDA_TARGET_FLAGS)

# Compiler preprocessor
CPU_CPP_FLAGS := -Iinclude # project header files
CPU_CPP_FLAGS += -I/usr/include/x86_64-linux-gnu/ # global include headers
CUDA_CPP_FLAGS := -I/usr/local/cuda/include/

# Linker
CPU_LDFLAGS := -fopenmp -L/usr/local/x86_64-linux-gnu
CUDA_LDFLAGS := -L/usr/local/cuda/lib64/ 
CPU_TESTS_LDFLAGS := -lgtest -lgtest_main
CPU_BENCHES_LDFLAGS := -lbenchmark -lbenchmark_main 

# Libraries
CPU_LIBS := -lopenblas64
CUDA_LIBS := -lcudart -lcuda -lcublas

# Folders
SRC_DIR := src
BUILD_DIR := build
TESTS_DIR := tests
BENCHES_DIR := benches

# Executables
EXE_NAME := randomForest
EXE := $(BUILD_DIR)/$(EXE_NAME)
CPU_TESTS_EXE_NAME := randomForestTests
CPU_TESTS_EXE := $(BUILD_DIR)/$(CPU_TESTS_EXE_NAME)
CPU_BENCHES_EXE_NAME := randomForestBenches
CPU_BENCHES_EXE := $(BUILD_DIR)/$(CPU_BENCHES_EXE_NAME)

# Sources
CPU_SOURCES := $(wildcard $(SRC_DIR)/*.cpp)
CPU_TESTS_SOURCES := $(wildcard $(TESTS_DIR)/*.cpp)
CPU_BENCHES_SOURCES := $(wildcard $(BENCHES_DIR)/*.cpp)
CUDA_SOURCES := $(wildcard $(SRC_DIR)/*.cu)

# Objects
CPU_SRC_OBJECTS := $(CPU_SOURCES:$(SRC_DIR)/%.cpp=$(BUILD_DIR)/%.o)
CPU_TESTS_OBJECTS := $(CPU_TESTS_SOURCES:$(TESTS_DIR)/%.cpp=$(BUILD_DIR)/%.o)
CPU_BENCHES_OBJECTS := $(CPU_BENCHES_SOURCES:$(BENCHES_DIR)/%.cpp=$(BUILD_DIR)/%.o)
CUDA_OBJECTS := $(CUDA_SOURCES:$(SRC_DIR)/%.cu=$(BUILD_DIR)/%.o)

# Rules -----------------------------------------

# Avoiding creating files my making these "commands only"
.PHONY: all run compile clean datasets tests

# by default, build the project
all: compile

# run the main executable
run: compile
	./$(EXE)

# compile (build) the project (without tests)
compile: $(EXE)

# Linking executable
$(EXE): $(BUILD_DIR)/main.o $(CPU_SRC_OBJECTS) $(CUDA_OBJECTS)| $(BUILD_DIR)
	$(CPU_CC) $^ $(CUDA_LIBS) $(CPU_LIBS) -o $@ $(CPU_LDFLAGS) $(CUDA_LDFLAGS) 

# Compiling c++ files
$(CPU_SRC_OBJECTS) : $(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp | $(BUILD_DIR)
	$(CPU_CC) $(CXX_FLAGS) $(CPU_CPP_FLAGS) $(CUDA_CPP_FLAGS) -c $< -o $@

# Compiling cuda files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cu | $(BUILD_DIR)
	$(GPU_CC) $(CXXFLAGS) $(CUDA_CXX_FLAGS) $(CPU_CPP_FLAGS) $(CUDA_CPP_FLAGS) -c $< -o $@

# Creating build folder if it does not exist
$(BUILD_DIR):
		mkdir -p $@


# TESTS -----------------------------------------
# run tests
tests: compile-tests
	./$(CPU_TESTS_EXE)

# Compile tests
compile-tests: $(CPU_TESTS_EXE)

# Linking tests
# We link all tests and src files, but we exclude main.o because we don't want two main function in the same executable
$(CPU_TESTS_EXE): $(filter-out $(BUILD_DIR)/main.o, $(CPU_SRC_OBJECTS)) $(CPU_TESTS_OBJECTS) | $(BUILD_DIR)
	$(CPU_CC) $^ $(CUDA_LIBS) $(CPU_LIBS) -o $@ $(CPU_LDFLAGS) $(CUDA_LDFLAGS) $(CPU_TESTS_LDFLAGS) 

# Compiling tests objects
$(CPU_TESTS_OBJECTS) : $(BUILD_DIR)/%.o: $(TESTS_DIR)/%.cpp | $(BUILD_DIR)
	$(CPU_CC) $(CXX_FLAGS) $(CPU_CPP_FLAGS) $(CUDA_CPP_FLAGS) -c $< -o $@


# BENCHES
benches: compile-benches
	./$(CPU_BENCHES_EXE)
	# it would be possible to generate output with the following
	# ./$(CPU_BENCHES_EXE) --benchmark_out=my_output_file.json

# Compile benches
compile-benches: $(CPU_BENCHES_EXE)

# Linking tests
# We link all tests and src files, but we exclude main.o because we don't want two main function in the same executable
$(CPU_BENCHES_EXE): $(filter-out $(BUILD_DIR)/main.o, $(CPU_SRC_OBJECTS)) $(CPU_BENCHES_OBJECTS) | $(BUILD_DIR)
	$(CPU_CC) $^ $(CUDA_LIBS) $(CPU_LIBS) -o $@ $(CPU_LDFLAGS) $(CUDA_LDFLAGS) $(CPU_BENCHES_LDFLAGS) 

# Compiling benches objects
$(CPU_BENCHES_OBJECTS) : $(BUILD_DIR)/%.o: $(BENCHES_DIR)/%.cpp | $(BUILD_DIR)
	$(CPU_CC) $(CXX_FLAGS) $(CPU_CPP_FLAGS) $(CUDA_CPP_FLAGS) -c $< -o $@

# SCRIPTS ---------------------------------------
# deploy base cuda image to the gitlab registry
deploy-base-image:
	./tools/deploy_base_cuda_image.sh

# CLEAN -----------------------------------------
# clean build files
clean:
	rm -rf $(BUILD_DIR)