# Test configuration for ONYX-GATE
message(STATUS "Configuring test executable...")

# Verify GoogleTest is available
if(NOT TARGET gtest OR NOT TARGET gtest_main)
    message(FATAL_ERROR "GoogleTest targets not available! Check root CMakeLists.txt")
endif()

# Create test executable
add_executable(onyx-gate-tests
        test_logger.cpp
        ../src/logger.c  # Include logger source for testing
)

# Link with Google Test
target_link_libraries(onyx-gate-tests
        PRIVATE
        gtest
        gtest_main
)

# Include directories
target_include_directories(onyx-gate-tests
        PRIVATE
        ${CMAKE_SOURCE_DIR}/src
        ${CMAKE_SOURCE_DIR}/external/googletest/googletest/include
)

# Compiler flags specific to tests
target_compile_options(onyx-gate-tests
        PRIVATE
        -Wall
        -Wextra
        -O2
)

# Add test definitions
target_compile_definitions(onyx-gate-tests
        PRIVATE
        TESTING_BUILD=1
        ONYX_GATE_VERSION="${PROJECT_VERSION}"
)

# Register tests with CTest (CLion integration)
include(GoogleTest)
gtest_discover_tests(onyx-gate-tests
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        PROPERTIES
        TIMEOUT 30
        LABELS "unit;core"  # CLion can filter by labels
)

# Add custom test target for easier running
add_custom_target(run-tests
        COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure --parallel ${CMAKE_BUILD_PARALLEL_LEVEL}
        DEPENDS onyx-gate-tests
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "🧪 Running ONYX-GATE test suite..."
)

# CLion test runner integration
set_target_properties(onyx-gate-tests PROPERTIES
        FOLDER "Tests"                    # Organize in CLion project tree
        VS_DEBUGGER_WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
)

message(STATUS "🧪 Test configuration complete")
message(STATUS "  • Test executable: onyx-gate-tests")
message(STATUS "  • Custom target: run-tests")
message(STATUS "  • CTest integration: enabled")
message(STATUS "  • CLion: Use Test Runner tab for individual tests")