//
//  OHMRingBuffer.m
//  OHMTagLib
//
//  Created by Tobias Hieta on 2011-02-07.
//  Copyright 2011 OHM Interactive. All rights reserved.
//

#import "OHMRingBuffer.h"


@implementation OHMRingBuffer

@synthesize storageSize;

#pragma mark Properties

-(NSUInteger)freeSpace
{
    @synchronized(self) {
        return storageSize - [storage length];
    }
}

-(NSUInteger)usedSpace
{
    @synchronized(self) {
        return [storage length];
    }
}

-(BOOL)canRead
{
    @synchronized(self) {
        return [storage length] > 0;
    }
}

-(BOOL)canWrite
{
    @synchronized(self) {
        return storageSize > [storage length];
    }
}

#pragma mark public

-(id)initWithStorageSize:(NSUInteger)size
{
    if ((self = [super init])) {
        storageSize = size;
        storage = [[OHMData alloc] initWithSize:size];
        
        freeCondition = [NSCondition new];
        usedCondition = [NSCondition new];
    }
    return self;
}

-(NSData*)popData:(NSUInteger)bytes waitForData:(BOOL)wait
{
    [usedCondition lock];
    while (self.usedSpace < 1) {
        if (wait) {
            GTMLoggerDebug(@"waiting for data");
            [usedCondition wait];
        } else {
            GTMLoggerDebug(@"not waiting for data");
            [usedCondition unlock];
            return nil;
        }
    }
    [usedCondition unlock];
        
    NSData *ret;
    @synchronized(self) {
        ret = [storage popDataWithRange:NSMakeRange(0, MIN (bytes, [storage length]))];
    }
    
    [freeCondition broadcast];
    return ret;
}

-(BOOL)addData:(NSData *)data waitForFreeSpace:(BOOL)wait
{
    if ([data length] > self.storageSize) {
        NSAssert(NO, @"You tried to write something to the ringbuffer that doesn't fit.");
    }
        
    [freeCondition lock];
    while (self.freeSpace < [data length]) {
        if (wait) {
            GTMLoggerDebug(@"Waiting for freeSpace");
            [freeCondition wait];
        } else {
            return NO;
        }
    }
    [freeCondition unlock];
    
    @synchronized(self) {
        [storage addData:data];
    }
    [usedCondition broadcast];
        
    return YES;
}

-(void)dealloc
{
    [storage release];
    [freeCondition release];
    [usedCondition release];
    
    [super dealloc];
}

@end
