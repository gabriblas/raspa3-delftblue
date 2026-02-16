cmake_minimum_required(VERSION 3.29)

project(raspa3
  VERSION "${RASPA_VERSION}"
  DESCRIPTION ""
  HOMEPAGE_URL "https://github.com/iraspa/raspa3"
  LANGUAGES C CXX)

  
# Set the version of C++ for the project
set(CMAKE_CXX_STANDARD_REQUIRED ON)
if(WIN32)
  set(CMAKE_CXX_STANDARD 23)
else()
  set(CMAKE_CXX_STANDARD 26)
endif()

# Turning off extensions avoids an issue with the clang 16 compiler
# clang 17 and greater can avoid this setting
# set(CMAKE_CXX_EXTENSIONS OFF)

set(MSVC_WARNINGS /W4 /w14242 /w14254 /w14263 /w14265 /w14287 /we4289 /w14296 /w14311 /w14545 /w14546 /w14547 /w14549 /w14555 /w14619 /w14640 /w14826 /w14826 /w14905 /w14906 /w14928 /permissive-)
set(CLANG_WARNINGS  -Wall -Wextra -Wshadow -Wnon-virtual-dtor -Wold-style-cast -Wcast-align -Wunused -Woverloaded-virtual -Wpedantic -Wconversion -Wsign-conversion -Wnull-dereference -Wdouble-promotion -Wformat=2 -Wimplicit-fallthrough -Wno-gnu-anonymous-struct -Wno-error=deprecated-declarations -Wno-error=nan-infinity-disabled -Wno-deprecated-declarations -Wno-nan-infinity-disabled -Wno-unknown-warning-option)
set(GCC_WARNINGS -Wall -Wextra -Wmisleading-indentation -Wduplicated-cond -Wduplicated-branches -Wlogical-op -Wuseless-cast -Wsuggest-override)

if(MSVC)
  set(PROJECT_WARNINGS_CXX ${MSVC_WARNINGS})
elseif(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
  set(PROJECT_WARNINGS_CXX ${CLANG_WARNINGS})
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  set(PROJECT_WARNINGS_CXX ${GCC_WARNINGS})
endif()

add_compile_definitions(USE_LEGACY_HEADERS VERSION=${PROJECT_VERSION})
# add_compile_definitions(USE_STD_IMPORT VERSION=${PROJECT_VERSION})
# add_compile_definitions(USE_PRECOMPILED_HEADERS VERSION=${PROJECT_VERSION})
# add_compile_definitions(VERSION=${PROJECT_VERSION})


find_package(ZLIB REQUIRED)
find_package(BLAS REQUIRED)
find_package(LAPACK REQUIRED)
find_package(OpenMP)
find_package(HDF5 REQUIRED COMPONENTS CXX)
find_package(OpenCL REQUIRED)
find_package(MPI REQUIRED)

# Imported voro++ (provided by delftblue)
add_library(voro++ STATIC IMPORTED)
set_target_properties(voro++ PROPERTIES
  IMPORTED_LOCATION "${VORO_LIBRARY}"
  INTERFACE_INCLUDE_DIRECTORIES "${VORO_INCLUDE_DIR}"
)

# Interface target for common dependencies (consistent flags for modules)
add_library(raspa_dependencies INTERFACE)
target_link_libraries(raspa_dependencies INTERFACE
  MPI::MPI_CXX
  HDF5::HDF5
  OpenCL::OpenCL
  ZLIB::ZLIB
  ${BLAS_LIBRARIES}
  ${LAPACK_LIBRARIES}
  voro++
)

if(OpenMP_CXX_FOUND)
  target_link_libraries(raspa_dependencies INTERFACE OpenMP::OpenMP_CXX)
endif()

target_compile_options(raspa_dependencies INTERFACE ${PROJECT_WARNINGS_CXX})

# Building
add_subdirectory(src)

if(BUILD_APP)
  add_subdirectory(data)
  add_subdirectory(examples)
  add_subdirectory(app)
endif()

if(BUILD_CLI)
  add_subdirectory(cli)
endif()

# for delftblue, all the following should be false
if(BUILD_DOXYGEN)
  add_subdirectory(docs)
endif()

add_subdirectory(packaging)

if(BUILD_TESTING)
  add_subdirectory(tests)
endif()

if(BUILD_BENCHMARKS)
  add_subdirectory(benchmarks)
endif()

if(BUILD_PYTHON)
  add_subdirectory(raspa)
endif()
