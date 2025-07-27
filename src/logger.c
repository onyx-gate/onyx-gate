/*
 * ONYX-GATE - The elegant gateway to unbreakable security
 * Simple Logger Implementation
 * 
 * SPDX-License-Identifier: MIT
 * Copyright (c) 2025 ONYX-GATE Project
 */

#include <stdio.h>
#include <time.h>
#include <string.h>

// Simple logging function that outputs to console with timestamp
void log_info(const char *message) {
    // Get current time
    time_t now = time(NULL);
    struct tm *timeinfo = localtime(&now);
    
    // Format timestamp
    char timestamp[32];
    strftime(timestamp, sizeof(timestamp), "%Y-%m-%d %H:%M:%S", timeinfo);
    
    // Print formatted message
    printf("[%s] INFO  %s\n", timestamp, message);
    
    // Flush output immediately (important for PBA environment)
    fflush(stdout);
}

// Test function to verify logger works
int test_logger(void) {
    log_info("Logger test started");
    log_info("Testing log_info function");
    log_info("Logger test completed");
    return 0; // Success
}
