//
//  OHMData.m
//  OHMTagLib
//
//  Created by Tobias Hieta on 2011-01-10.
//  Copyright 2011 OHM Interactive. All rights reserved.
//

#import "OHMData.h"
#import "GTMLogger.h"

#define EXTRA_DEBUG 1

#if EXTRA_DEBUG
#define extraLogDebug(...) GTMLoggerDebug (__VA_ARGS__)
#define extraLogError(...) GTMLoggerError (__VA_ARGS__)
#else
#define extraLogDebug(...) do {} while(0)
#define extraLogError(...) do {} while(0)
#endif

@implementation OHMData

@synthesize shouldExpand;

-(NSUInteger)freeSpace
{
    return dataBufferSize - dataBufferLength;
}

-(NSUInteger)dataSize
{
    return dataBufferSize;
}

-(NSUInteger)length
{
    return dataBufferLength;
}

-(id)initWithSize:(NSUInteger)size
{
	if ((self = [super init])) {
		dataBuffer = malloc (size);
        memset(dataBuffer, 0, size);
		dataBufferSize = size;
		dataBufferLength = 0;
		self.shouldExpand = YES;
	}
	
	return self;
}

-(id)init
{
	if ((self = [self initWithSize:4096])) {
	}
	return self;
}

-(BOOL)addData:(NSData *)data
{
    if ([data length] > self.freeSpace) {
        if (self.shouldExpand) {
            /* realloc */
            extraLogDebug(@"need to realloc because freeSpace is %d", self.freeSpace);
            NSUInteger newSize = MAX (dataBufferSize * 2, [data length] + dataBufferSize);
            dataBuffer = realloc (dataBuffer, newSize);
            if (!dataBuffer) {
                extraLogError(@"failed to realloc the buffer to size: %d", newSize);
            }
            memset(dataBuffer + dataBufferSize, 0, newSize-dataBufferSize);
            dataBufferSize = newSize;
            extraLogDebug(@"Reallocing buffer to size %d", newSize);
        } else {
            extraLogError(@"wanted to add bytes, but shouldExpand was not set correctly.");
            return NO;
        }
    }
    [data getBytes:dataBuffer+dataBufferLength length:[data length]];
    dataBufferLength += [data length];
    return YES;
}

-(NSData*)getData
{
    return [NSData dataWithBytes:dataBuffer length:dataBufferLength];
}

-(NSData*)popData
{
    NSData *ret = [self getData];
    /* reset data */
    dataBufferLength = 0;
    return ret;
}

-(NSData*)getDataWithRange:(NSRange)range
{
    NSUInteger rangeEnd = range.length + range.location;
    if (rangeEnd > dataBufferLength) {
        extraLogError(@"range is out of bounds");
        return nil;
        /* TODO: raise exception? */
    }
    return [NSData dataWithBytes:dataBuffer+range.location length:range.length];
}

-(NSData*)popDataWithRange:(NSRange)range
{
    NSData *data = [self getDataWithRange:range];
    [self discardDataWithRange:range];
    return data;
}

-(void)discardDataWithRange:(NSRange)range; {
    NSUInteger rangeEnd = range.location + range.length;
    NSAssert(rangeEnd <= dataBufferLength, @"Need to have a range that is within the size of the buffer");
    if (rangeEnd != dataBufferLength) {
        memmove (dataBuffer + range.location, 
                 dataBuffer + rangeEnd,
                 dataBufferLength - rangeEnd);
    }
    dataBufferLength -= range.length;
    memset(dataBuffer + dataBufferLength, 0, range.length);
}

-(void)removeAllData
{
    dataBufferLength = 0;
}


-(void)dealloc
{
	free (dataBuffer);
	[super dealloc];
}

@end
