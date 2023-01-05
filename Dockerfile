# A custom image to get cuda tools with blas, g++ and make

# careful, this image does not include the project source code.
# It will be used later in the pipeline file as a base iamge to run the project code.
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

RUN apt update
# G++, make
RUN apt -y install build-essential
# cmake
RUN apt -y install cmake
# BLAS
RUN apt -y install libopenblas-dev libopenblas64-pthread-dev
# google test
RUN apt -y install libgtest-dev
# google benchmark
RUn apt -y install libbenchmark-dev
