//
//  OHMPositionalBuffer.m
//  OHMTagLib
//
//  Created by Tobias Hieta on 2011-01-03.
//  Copyright 2011 OHM Interactive. All rights reserved.
//

#import "OHMPositionalBuffer.h"
#import "GTMLogger.h"

@implementation OHMPositionalBuffer

@synthesize consumerDelegate;
@synthesize sourceDelegate;


-(id)init
{
	if ((self = [super init])) {
		buffer = [OHMData new];
	}
	return self;
}

-(id)initWithData:(NSData *)data
{
	if ((self = [self init])) {
		[buffer addData:data];
	}
	return self;
}

-(NSUInteger)length
{
	@synchronized(buffer) {
		return [buffer length];
	}
}

-(NSData*)peekDataFromCurrentPosition:(NSUInteger)numBytes error:(NSError **)err
{
    @synchronized(buffer) {
        NSUInteger buflen = [buffer length];
        if (numBytes > buflen) {
            [self getMoreData:numBytes - buflen];
        }
        if (buflen == 0) {
            return nil;
        }
        
        NSUInteger readLength = MIN(buflen, numBytes);
        NSData *ret = [buffer getDataWithRange:NSMakeRange(0, readLength)];
        if (!ret) {
            GTMLoggerDebug(@"Couldn't peek data from OHMData");
            return nil;
        }
        return ret;
    }
}

-(NSData*)getDataFromCurrentPosition:(NSUInteger)numBytes error:(NSError **)err
{
	@synchronized(buffer) {
        NSUInteger buflen = [buffer length];
		if (numBytes > buflen) {
			/* need more data */
			[self getMoreData:numBytes - buflen];
		}
		
		if (buflen == 0) {
			return nil;
		}
		
		NSUInteger readLength = MIN(buflen, numBytes);
		NSData *ret = [buffer popDataWithRange:NSMakeRange(0, readLength)];
		if (!ret) {
			GTMLoggerDebug(@"couldn't get subdata!");
			return nil;
		}
				
		return ret;
		
	}
}

-(void)addData:(NSData *)data
{
	@synchronized(buffer) {
		[buffer addData:data];
        if ([consumerDelegate respondsToSelector:@selector(bufferHaveMoreData:)]) {
            [consumerDelegate bufferHaveMoreData:self];
        }
	}
}

-(BOOL)jumpPosition:(NSUInteger)numBytes
{
	@synchronized(buffer) {
        NSUInteger buflen = [buffer length];
        if (buflen >= numBytes) {
			[buffer discardDataWithRange:NSMakeRange(0, numBytes)];
			/* forward the buffer */            
        }
        else {
            /* reset buffer */
            [buffer removeAllData];
            BOOL hasDelegate = [sourceDelegate respondsToSelector:@selector(buffer:jumpToPosition:)];
			if (hasDelegate) {
				[sourceDelegate buffer:self jumpToPosition:(numBytes - buflen)];
            }
            return hasDelegate;
		}
    }
	return YES;
}

-(void)getMoreData:(NSUInteger)length_
{
	if ([sourceDelegate respondsToSelector:@selector(buffer:needMoreData:)]) {
		[sourceDelegate buffer:self needMoreData:length_];
	}
	
}

@end
