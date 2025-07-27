/*
 * ONYX-GATE - The elegant gateway to unbreakable security
 * Fixed Google Tests for Logger
 * 
 * SPDX-License-Identifier: MIT
 * Copyright (c) 2025 ONYX-GATE Project
 */

#include <gtest/gtest.h>
#include <string>
#include <cstdio>
#include <unistd.h>
#include <fcntl.h>

// C functions to test
extern "C" {
    void log_info(const char *message);
    int test_logger(void);
}

// Helper class to capture stdout (printf output)
class StdoutCapture {
private:
    int stdout_fd;
    int pipe_fd[2];
    std::string captured_output;
    
public:
    StdoutCapture() {
        stdout_fd = dup(STDOUT_FILENO);
        pipe(pipe_fd);
        dup2(pipe_fd[1], STDOUT_FILENO);
        close(pipe_fd[1]);
    }
    
    ~StdoutCapture() {
        dup2(stdout_fd, STDOUT_FILENO);
        close(stdout_fd);
        close(pipe_fd[0]);
    }
    
    std::string getOutput() {
        fflush(stdout);
        char buffer[1024];
        ssize_t bytes_read = read(pipe_fd[0], buffer, sizeof(buffer) - 1);
        if (bytes_read > 0) {
            buffer[bytes_read] = '\0';
            captured_output += buffer;
        }
        return captured_output;
    }
};

// Test the basic log_info function with proper stdout capture
TEST(LoggerTest, BasicLogInfo) {
    StdoutCapture capture;
    
    // Test the function
    log_info("Test message");
    
    // Get captured output
    std::string output = capture.getOutput();
    
    // Check output contains our message
    EXPECT_TRUE(output.find("Test message") != std::string::npos);
    EXPECT_TRUE(output.find("INFO") != std::string::npos);
}

// Test that log_info handles empty string gracefully
TEST(LoggerTest, NullMessageHandling) {
    StdoutCapture capture;
    
    // This should not crash
    EXPECT_NO_THROW(log_info(""));
    
    std::string output = capture.getOutput();
    EXPECT_TRUE(output.find("INFO") != std::string::npos);
}

// Test the test_logger function
TEST(LoggerTest, TestLoggerFunction) {
    EXPECT_EQ(0, test_logger());
}

// Test that logger produces timestamps
TEST(LoggerTest, TimestampGeneration) {
    StdoutCapture capture1;
    log_info("First message");
    std::string output1 = capture1.getOutput();
    
    // Small delay
    usleep(1000);
    
    StdoutCapture capture2;
    log_info("Second message");
    std::string output2 = capture2.getOutput();
    
    // Both should have timestamps
    EXPECT_TRUE(output1.find("First message") != std::string::npos);
    EXPECT_TRUE(output2.find("Second message") != std::string::npos);
    EXPECT_TRUE(output1.find("[") != std::string::npos); // Timestamp bracket
    EXPECT_TRUE(output2.find("[") != std::string::npos); // Timestamp bracket
}

// Test message formatting including Unicode
TEST(LoggerTest, MessageFormatting) {
    StdoutCapture capture;
    
    log_info("🖤 ONYX-GATE Test");
    
    std::string output = capture.getOutput();
    EXPECT_TRUE(output.find("ONYX-GATE Test") != std::string::npos);
    EXPECT_TRUE(output.find("INFO") != std::string::npos);
}

// Alternative approach: Test functional behavior instead of output capture
TEST(LoggerTest, FunctionalTest) {
    // Test that logger function completes without crashing
    EXPECT_NO_THROW(log_info("Functional test"));
    EXPECT_NO_THROW(log_info(""));
    EXPECT_NO_THROW(log_info("Test with special chars: 🖤"));
    
    // Test logger works with various message lengths
    std::string long_message(500, 'x');
    EXPECT_NO_THROW(log_info(long_message.c_str()));
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}