/*
 * ONYX-GATE - The elegant gateway to unbreakable security
 * Main PBA Application
 * 
 * SPDX-License-Identifier: MIT
 * Copyright (c) 2025 ONYX-GATE Project
 */

#include <stdio.h>
#include <unistd.h>
#include <string.h>

// Simple logger function declaration
void log_info(const char* message);

// Clear screen and show centered message
void show_centered_message(void)
{
    // Clear screen (ANSI escape codes)
    printf("\033[2J\033[H");

    // Move to center and display message
    printf("\n\n\n\n\n\n\n\n");
    printf("          🖤 ONYX-GATE - Hello World! 🖤\n");
    printf("     The elegant gateway to unbreakable security\n");
    printf("\n");
    printf("                Version: %s\n", ONYX_GATE_VERSION);
    printf("                Build: %s\n", ONYX_GATE_BUILD_DATE);
    printf("\n");
    printf("         Press Enter to continue...\n");
}

int main(const int argc, char* argv[])
{
    // Log startup
    log_info("🖤 ONYX-GATE PBA starting...");
    log_info("The elegant gateway to unbreakable security");

    // Check for test mode
    if (argc > 1 && strcmp(argv[1], "--test") == 0)
    {
        log_info("Test mode: displaying message and exiting");
        show_centered_message();
        printf("\n[TEST MODE] Exiting after 2 seconds...\n");
        sleep(2);
        log_info("Test completed successfully");
        return 0;
    }

    // Normal mode - show message and wait
    log_info("Displaying main interface");
    show_centered_message();

    // Wait for user input
    char input[10];
    if (fgets(input, sizeof(input), stdin))
    {
        log_info("User pressed Enter, continuing...");
    }

    // In real PBA, this would unlock drive and reboot
    log_info("PBA simulation completed");
    log_info("In production: drive would be unlocked and system rebooted");

    log_info("🛑 ONYX-GATE PBA shutting down");
    return 0;
}
