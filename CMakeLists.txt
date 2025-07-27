cmake_minimum_required(VERSION 3.16)
project(onyx-gate VERSION 2.0.0 LANGUAGES C CXX)

# C standard
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Build options
option(BUILD_TESTING "Build tests" ON)

# Compiler flags for all targets
add_compile_options(-Wall -Wextra)

# Set build type default
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type" FORCE)
endif()

# CLion IDE integration
set_property(GLOBAL PROPERTY USE_FOLDERS ON)  # Enable folder organization in CLion

# Print configuration info
message(STATUS "=== ONYX-GATE Configuration ===")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "C Compiler: ${CMAKE_C_COMPILER}")
message(STATUS "CXX Compiler: ${CMAKE_CXX_COMPILER}")
message(STATUS "Testing enabled: ${BUILD_TESTING}")
message(STATUS "IDE: CLion integration enabled")

# Check submodule initialization with CLion-friendly messages
if(NOT EXISTS "${CMAKE_SOURCE_DIR}/external/googletest/CMakeLists.txt")
    message(FATAL_ERROR
            "🔴 GoogleTest submodule not found!\n"
            "In CLion: VCS → Git → Update Submodules\n"
            "Or terminal: git submodule update --init --recursive")
endif()

if(NOT EXISTS "${CMAKE_SOURCE_DIR}/external/openssl/Configure")
    message(FATAL_ERROR
            "🔴 OpenSSL submodule not found!\n"
            "In CLion: VCS → Git → Update Submodules\n"
            "Or terminal: git submodule update --init --recursive")
endif()

# Add Google Test - always required for this project
message(STATUS "Adding GoogleTest from submodule...")
add_subdirectory(external/googletest EXCLUDE_FROM_ALL)

# Verify GoogleTest targets are available
if(NOT TARGET gtest)
    message(FATAL_ERROR "GoogleTest failed to create gtest target!")
endif()

if(NOT TARGET gtest_main)
    message(FATAL_ERROR "GoogleTest failed to create gtest_main target!")
endif()

message(STATUS "GoogleTest configured successfully")

# Main source
add_subdirectory(src)

# Tests - always build if BUILD_TESTING is ON
if(BUILD_TESTING)
    enable_testing()
    message(STATUS "Configuring tests...")
    add_subdirectory(tests)
    message(STATUS "Tests configured successfully")
else()
    message(STATUS "Testing disabled")
endif()

# Set version in code - must come after target creation
if(TARGET onyx-gate-pba)
    target_compile_definitions(onyx-gate-pba
            PRIVATE
            ONYX_GATE_VERSION="${PROJECT_VERSION}"
            ONYX_GATE_BUILD_DATE="${CMAKE_BUILD_DATE}"
    )
    message(STATUS "Version definitions added to onyx-gate-pba")
else()
    message(WARNING "onyx-gate-pba target not found for version definitions")
endif()

# Print summary with CLion-friendly formatting
message(STATUS "=== 🎉 Configuration Complete ===")
message(STATUS "Targets created:")
message(STATUS "  🚀 onyx-gate-pba (main application)")
if(BUILD_TESTING)
    message(STATUS "  🧪 onyx-gate-tests (test suite)")
    message(STATUS "")
    message(STATUS "🔧 CLion Usage:")
    message(STATUS "  • Build: Ctrl+F9 or Build → Build Project")
    message(STATUS "  • Run tests: Right-click test → Run")
    message(STATUS "  • Debug: Set breakpoints → Debug button")
    message(STATUS "  • Run main: Select 'onyx-gate-pba' → Run")
endif()
message(STATUS "Ready to develop! 🚀")