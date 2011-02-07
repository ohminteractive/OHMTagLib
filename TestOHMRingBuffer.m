//
//  TestOHMRingBuffer.m
//  OHMTagLib
//
//  Created by Tobias Hieta on 2011-02-07.
//  Copyright 2011 OHM Interactive. All rights reserved.
//

#import "TestOHMRingBuffer.h"
#import "GTMLogger.h"

@implementation TestOHMRingBuffer

-(void)setUp
{
    buffer = [[OHMRingBuffer alloc] initWithStorageSize:1024];
}

-(void)testFill
{
    char buf[100];
    
    for (int i = 0; i < 10 ; i++) {
        memset(buf, i, 100);
        
        BOOL ret = [buffer addData:[NSData dataWithBytes:buf length:100] waitForFreeSpace:NO];
        STAssertTrue(ret, @"Couldn't write to the buffer!");
    }
    
    STAssertEquals((NSUInteger)1000, [buffer usedSpace], @"The buffer should have 1000 bytes");
}


-(void)testRead
{
    char buf[100];
    
    memset(buf, 42, 100);
    NSData *d = [NSData dataWithBytes:buf length:100];
    [buffer addData:d waitForFreeSpace:NO];
    
    NSData *d2 = [buffer popData:100 waitForData:NO];
    STAssertTrue([d2 isEqualToData:d], @"We should get what we put in.");
    
}

-(void)testWriteOOB
{
    char buf[1200];
    memset (buf, 42, 1200);
    NSData *d = [NSData dataWithBytes:buf length:1200];
    STAssertThrows([buffer addData:d waitForFreeSpace:NO], @"We should be asserted here.");
}

-(void)testCanWrite
{
    char buf[1024];
    memset(buf, 42, 1024);
    NSData *d = [NSData dataWithBytes:buf length:1024];
    
    STAssertTrue([buffer canWrite], @"We should be able to write now...");
    
    [buffer addData:d waitForFreeSpace:NO];
    STAssertFalse([buffer canWrite], @"We shouldn't be able to write");
}

-(void)testCanRead
{
    NSData *d = [NSData dataWithBytes:"123" length:3];
    STAssertFalse([buffer canRead], @"Nothing to read!");
    
    [buffer addData:d waitForFreeSpace:NO];
    STAssertTrue([buffer canRead], @"We should be able to read now!");
}

#pragma mark waited tests

-(void)testWriteWait
{
    NSOperationQueue *queue = [NSOperationQueue new];
    
    char buf[1024];
    memset(buf, 42, 1024);
    NSData *d = [NSData dataWithBytes:buf length:1024];
    [buffer addData:d waitForFreeSpace:NO];
    
    /* buffer is now filled. let's spawn a operation that will wait for write */
    
    [queue addOperationWithBlock:^{
//        [NSThread sleepForTimeInterval:1];
        NSData *d2 = [NSData dataWithBytes:"123" length:3];
        [buffer retain];
        [buffer addData:d2 waitForFreeSpace:YES];
        [buffer release];
        GTMLoggerDebug(@"done!");
    }];
    
    BOOL done = NO;
    int counts = 0;
    
    while (YES) {
        
        GTMLoggerDebug(@"enter runloop");
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        GTMLoggerDebug(@"exit runloop %d", counts);
        
        counts ++;
        
        [buffer popData:10 waitForData:NO];
        
        if ([buffer canWrite]) {
            GTMLoggerDebug(@"Thread is done, let's exit!");
            done = YES;
            break;
        } else if (counts > 3) {
            GTMLoggerDebug(@"Three seconds and no dice. Failing");
            break;
        }
    }
    
    STAssertTrue(done, @"We didn't get a write :/");
}

-(void)testReadWait
{
    NSOperationQueue *queue = [NSOperationQueue new];
    
    char buf[1024];
    memset(buf, 42, 1024);
    NSData *d = [NSData dataWithBytes:buf length:1024];
    
    /* buffer is now empty. let's spawn a operation that will wait for read */
    
    [queue addOperationWithBlock:^{
        [buffer retain];
        [buffer popData:1024 waitForData:YES];
        [buffer release];
        GTMLoggerDebug(@"done!");
    }];
    
    BOOL done = NO;
    int counts = 0;
    
    while (YES) {
        
        GTMLoggerDebug(@"enter runloop");
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        GTMLoggerDebug(@"exit runloop %d", counts);

        if (counts == 0) {
            [buffer addData:d waitForFreeSpace:NO];
        }
        
        counts ++;
        
        
        if (![buffer canRead]) {
            GTMLoggerDebug(@"Thread is done, let's exit!");
            done = YES;
            break;
        } else if (counts > 3) {
            GTMLoggerDebug(@"Three seconds and no dice. Failing");
            break;
        }
    }
    
    STAssertTrue(done, @"We didn't get a read :/");
}


-(void)tearDown
{
    [buffer release];
}

@end
