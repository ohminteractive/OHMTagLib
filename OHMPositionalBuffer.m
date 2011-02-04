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

-(UInt64)length
{
	@synchronized(buffer) {
		return [buffer length];
	}
}

-(NSData*)peekDataFromCurrentPosition:(UInt64)numBytes error:(NSError **)err
{
    @synchronized(buffer) {
        if (numBytes > [buffer length]) {
            [self getMoreData:numBytes - [buffer length]];
        }
        if ([buffer length] == 0) {
            return nil;
        }
        
        UInt64 readLength = MIN([buffer length], numBytes);
        NSData *ret = [buffer getDataWithRange:NSMakeRange(0, readLength)];
        if (!ret) {
            GTMLoggerDebug(@"Couldn't peek data from OHMData");
            return nil;
        }
        return ret;
    }
}

-(NSData*)getDataFromCurrentPosition:(UInt64)numBytes error:(NSError **)err
{
	@synchronized(buffer) {
		if (numBytes > [buffer length]) {
			/* need more data */
			[self getMoreData:numBytes - [buffer length]];
		}
		
		if ([buffer length] == 0) {
			return nil;
		}
		
		UInt64 readLength = MIN([buffer length], numBytes);
		
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
		
		if (waitingForMoreData) {
			if ([consumerDelegate respondsToSelector:@selector(bufferHaveMoreData:)]) {
				[consumerDelegate bufferHaveMoreData:self];
			}
			waitingForMoreData = NO;
		}
	}
}

-(BOOL)jumpPosition:(UInt64)numBytes
{
	@synchronized(buffer) {
		if ([buffer length] < numBytes) {
			if ([sourceDelegate respondsToSelector:@selector(buffer:jumpToPosition:)]) {
				[sourceDelegate buffer:self jumpToPosition:numBytes];
				/* reset buffer */
				[buffer removeAllData];
				waitingForMoreData = YES;
			} else {
				return NO;
			}
		} else {
			/* forward the buffer */
			[buffer popDataWithRange:NSMakeRange(0, numBytes)];
		}
	}
	return YES;
}

-(void)getMoreData:(UInt64)length_
{
	waitingForMoreData = YES;
	
	if ([sourceDelegate respondsToSelector:@selector(buffer:needMoreData:)]) {
		[sourceDelegate buffer:self needMoreData:length_];
	}
	
}

@end
