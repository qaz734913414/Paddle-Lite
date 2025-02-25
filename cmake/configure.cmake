# Copyright (c) 2016 PaddlePaddle Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if(NOT WITH_PYTHON)
    add_definitions(-DPADDLE_NO_PYTHON)
endif(NOT WITH_PYTHON)

if(WITH_DSO)
    add_definitions(-DPADDLE_USE_DSO)
endif(WITH_DSO)

if(WITH_TESTING)
    add_definitions(-DPADDLE_WITH_TESTING)
endif(WITH_TESTING)

if(NOT WITH_PROFILER)
    add_definitions(-DPADDLE_DISABLE_PROFILER)
endif(NOT WITH_PROFILER)

if(WITH_AVX AND AVX_FOUND)
    set(SIMD_FLAG ${AVX_FLAG})
elseif(SSE3_FOUND)
    set(SIMD_FLAG ${SSE3_FLAG})
endif()

if(WIN32)
  # windows header option for all targets.
  add_definitions(-D_XKEYCHECK_H)
  # Use symbols instead of absolute path, reduce the cmake link command length. 
  SET(CMAKE_C_USE_RESPONSE_FILE_FOR_LIBRARIES 1)
  SET(CMAKE_CXX_USE_RESPONSE_FILE_FOR_LIBRARIES 1)
  SET(CMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS 1)
  SET(CMAKE_CXX_USE_RESPONSE_FILE_FOR_OBJECTS 1)
  SET(CMAKE_C_USE_RESPONSE_FILE_FOR_INCLUDES 1)
  SET(CMAKE_CXX_USE_RESPONSE_FILE_FOR_INCLUDES 1)
  SET(CMAKE_C_RESPONSE_FILE_LINK_FLAG "@")
  SET(CMAKE_CXX_RESPONSE_FILE_LINK_FLAG "@")

  # Specify the program to use when building static libraries
  SET(CMAKE_C_CREATE_STATIC_LIBRARY "<CMAKE_AR> lib <TARGET> <LINK_FLAGS> <OBJECTS>")
  SET(CMAKE_CXX_CREATE_STATIC_LIBRARY "<CMAKE_AR> lib <TARGET> <LINK_FLAGS> <OBJECTS>")

  # set defination for the dll export
  if (NOT MSVC)
    message(FATAL "Windows build only support msvc. Which was binded by the nvcc compiler of NVIDIA.")
  endif(NOT MSVC)
endif(WIN32)

if(WITH_PSLIB)
    add_definitions(-DPADDLE_WITH_PSLIB)
endif()

if(LITE_WITH_CUDA)
    add_definitions(-DLITE_WITH_CUDA)
    add_definitions(-DEIGEN_USE_GPU)

    FIND_PACKAGE(CUDA REQUIRED)

    if(${CUDA_VERSION_MAJOR} VERSION_LESS 7)
        message(FATAL_ERROR "Paddle needs CUDA >= 7.0 to compile")
    endif()

    if(NOT CUDNN_FOUND)
        message(FATAL_ERROR "Paddle needs cudnn to compile")
    endif()
    if(CUPTI_FOUND)
        include_directories(${CUPTI_INCLUDE_DIR})
        add_definitions(-DPADDLE_WITH_CUPTI)
    else()
        message(STATUS "Cannot find CUPTI, GPU Profiling is incorrect.")
    endif()
    set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS} "-Xcompiler ${SIMD_FLAG}")

    # Include cuda and cudnn
    include_directories(${CUDNN_INCLUDE_DIR})
    include_directories(${CUDA_TOOLKIT_INCLUDE})

elseif(WITH_AMD_GPU)
    add_definitions(-DPADDLE_WITH_HIP)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D__HIP_PLATFORM_HCC__")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D__HIP_PLATFORM_HCC__")
else()
    add_definitions(-DHPPL_STUB_FUNC)
    list(APPEND CMAKE_CXX_SOURCE_FILE_EXTENSIONS cu)
endif()

if (WITH_MKLML AND MKLML_IOMP_LIB)
    message(STATUS "Enable Intel OpenMP with ${MKLML_IOMP_LIB}")
    if(WIN32)
        # openmp not support well for now on windows
        set(OPENMP_FLAGS "")
    else(WIN32)
        set(OPENMP_FLAGS "-fopenmp")
    endif(WIN32)
    set(CMAKE_C_CREATE_SHARED_LIBRARY_FORBIDDEN_FLAGS ${OPENMP_FLAGS})
    set(CMAKE_CXX_CREATE_SHARED_LIBRARY_FORBIDDEN_FLAGS ${OPENMP_FLAGS})
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OPENMP_FLAGS}")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OPENMP_FLAGS}")
endif()

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${SIMD_FLAG}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${SIMD_FLAG}")

if(WITH_DISTRIBUTE)
  add_definitions(-DPADDLE_WITH_DISTRIBUTE)
endif()

if(WITH_GRPC)
    add_definitions(-DPADDLE_WITH_GRPC)
endif(WITH_GRPC)

if(WITH_BRPC_RDMA)
    add_definitions(-DPADDLE_WITH_BRPC_RDMA)
endif(WITH_BRPC_RDMA)

if(ON_INFER)
    add_definitions(-DPADDLE_ON_INFERENCE)
endif(ON_INFER)

if(WITH_WBAES)
    add_definitions(-DPADDLE_WITH_WBAES)
endif(WITH_WBAES)

if (REPLACE_ENFORCE_GLOG)
  add_definitions("-DREPLACE_ENFORCE_GLOG")
endif()

# for lite
# TODO(Superjomn) not work fine with the option
if (LITE_WITH_X86)
    add_definitions("-DLITE_WITH_X86")
endif()

if (LITE_WITH_ARM)
    add_definitions("-DLITE_WITH_ARM")
endif()

if (WITH_ARM_DOTPROD)
    add_definitions("-DWITH_ARM_DOTPROD")
endif()

if (LITE_WITH_NPU)
    add_definitions("-DLITE_WITH_NPU")
endif()

if (LITE_WITH_OPENCL)
    add_definitions("-DLITE_WITH_OPENCL")
endif()

if (LITE_WITH_FPGA)
add_definitions("-DLITE_WITH_FPGA")
endif()

if (LITE_WITH_PROFILE)
    add_definitions("-DLITE_WITH_PROFILE")
    if (LITE_WITH_PRECISION_PROFILE)
        add_definitions("-DLITE_WITH_PRECISION_PROFILE")
    endif()
endif()

if (LITE_WITH_LIGHT_WEIGHT_FRAMEWORK)
  add_definitions("-DLITE_WITH_LIGHT_WEIGHT_FRAMEWORK")
endif()

if (LITE_SHUTDOWN_LOG)
  add_definitions("-DLITE_SHUTDOWN_LOG")
endif()

if (LITE_ON_TINY_PUBLISH)
  add_definitions("-DLITE_ON_TINY_PUBLISH")
endif()
