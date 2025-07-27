# Main PBA application
add_executable(onyx-gate-pba
    main.c
    logger.c
)

# Include directories
target_include_directories(onyx-gate-pba
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# Compiler flags for security
target_compile_options(onyx-gate-pba
    PRIVATE
    -Wall
    -Wextra
    -O2
)

# Install
install(TARGETS onyx-gate-pba
        RUNTIME DESTINATION bin)
