//
//  OHMData.m
//  OHMTagLib
//
//  Created by Tobias Hieta on 2011-01-10.
//  Copyright 2011 OHM Interactive. All rights reserved.
//

#import "OHMData.h"
#import "GTMLogger.h"

//#define EXTRA_DEBUG

@implementation OHMData

@synthesize shouldExpand;

-(NSUInteger)freeSpace
{
	@synchronized(self) {
		return dataBufferSize - dataBufferLength;
	}
}

-(NSUInteger)dataSize
{
	@synchronized(self) {
		return dataBufferSize;
	}
}

-(NSUInteger)length
{
	@synchronized(self) {
		return dataBufferLength;
	}
}

-(id)initWithSize:(NSUInteger)size
{
	if ((self = [super init])) {
		dataBuffer = malloc (size);
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
	@synchronized(self) {
		if ([data length] > self.freeSpace) {
			if (self.shouldExpand) {
				/* realloc */
#ifdef EXTRA_DEBUG
				GTMLoggerDebug(@"need to realloc because freeSpace is %d", self.freeSpace);
#endif
				NSUInteger newSize = MAX (dataBufferSize * 2, [data length] + dataBufferSize);
				dataBuffer = realloc (dataBuffer, newSize);
#ifdef EXTRA_DEBUG
				if (!dataBuffer) {
					GTMLoggerError(@"failed to realloc the buffer to size: %d", newSize);
				}
#endif
				dataBufferSize = newSize;
#ifdef EXTRA_DEBUG
				GTMLoggerDebug(@"Reallocing buffer to size %d", newSize);
#endif
			} else {
				GTMLoggerError(@"wanted to add bytes, but shouldExpand was not set correctly.");
				return NO;
			}
		}
		[data getBytes:dataBuffer+dataBufferLength length:[data length]];
		dataBufferLength += [data length];
		return YES;
	}
}

-(NSData*)getData
{
	@synchronized(self) {
		return [NSData dataWithBytes:dataBuffer length:dataBufferLength];
	}
}

-(NSData*)popData
{
	@synchronized(self) {
		NSData *ret = [self getData];
		/* reset data */
		dataBufferLength = 0;
		return ret;
	}
}

-(NSData*)getDataWithRange:(NSRange)range
{
	@synchronized(self) {
		if (range.location < dataBufferLength &&
			range.location + range.length <= dataBufferLength) {
			return [NSData dataWithBytes:dataBuffer+range.location length:range.length];
		} else {
			GTMLoggerError(@"range is out of bounds");
			return nil;
			/* TODO: raise exception? */
		}
	}
	return nil;
}

-(NSData*)popDataWithRange:(NSRange)range
{
	@synchronized(self) {
		NSData *data = [self getDataWithRange:range];
		/* remove data that we got */
#ifdef EXTRA_DEBUG
		GTMLoggerDebug(@"loc + len = %d, dataBufferLength = %d", range.location + range.length, dataBufferLength);
#endif
		if ((range.location + range.length) <= dataBufferLength) {
			/* move the memory */
#ifdef EXTRA_DEBUG
			GTMLoggerDebug(@"memmove (%d, %d, %d)", range.location, range.location+range.length, dataBufferLength-(range.length + range.location));
#endif
			memmove (dataBuffer + range.location, 
					 dataBuffer + (range.location + range.length),
					 dataBufferLength - (range.location + range.length));
			dataBufferLength -= range.length;
		}
		return data;
	}
}

-(void)removeAllData
{
	@synchronized(self) {
		dataBufferLength = 0;
	}
}


-(void)dealloc
{
	free (dataBuffer);
	[super dealloc];
}

@end
