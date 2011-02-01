//
//  TestOHMData.m
//  OHMTagLib
//
//  Created by Tobias Hieta on 2011-01-17.
//  Copyright 2011 OHM Interactive. All rights reserved.
//

#import "TestOHMData.h"
#import "GTMLogger.h"

@implementation TestOHMData

-(void)setUp
{
	data = [[OHMData alloc] initWithSize:100];
}

-(void)testAdd
{
	NSData *d = [NSData dataWithBytes:"abc123" length:6];
	[data addData:d];
	STAssertEquals([data length], (NSUInteger)6, @"The size of data is wrong after an add!");
}

-(void)testGet
{
	NSData *d = [NSData dataWithBytes:"abc123" length:6];
	[data addData:d];
	NSData *d2 = [data getData];
	STAssertTrue([d isEqualToData:d2], @"Data is not the same!");
}

-(void)testRealloc
{
	char chars[200];
	memset (chars, 'b', 200);
	NSData *d = [NSData dataWithBytes:chars length:200];
	[data addData:d];
	STAssertEquals([data length], (NSUInteger)200, @"After realloc we should have bytes 200bytes");
	STAssertEquals([data dataSize], (NSUInteger)300, @"After realloc the buffer should be 200 bytes but was %d", [data dataSize]);
}

-(void)testReallocDouble
{
	char chars[200];
	memset (chars, 'b', 200);
	NSData *d = [NSData dataWithBytes:chars length:200];
	[data addData:d];
	[data addData:d];
	STAssertEquals([data length], (NSUInteger)400, @"After realloc we should have bytes 400bytes");
	STAssertEquals([data dataSize], (NSUInteger)600, @"After realloc the buffer should be 400 bytes but was %d", [data dataSize]);
}

-(void)testPopData
{
	NSData *d = [NSData dataWithBytes:"abc123" length:6];
	[data addData:d];
	NSData *d2 = [data popData];
	STAssertTrue([d isEqualToData:d2], @"Data is not the same!");
	STAssertEquals([data length], (NSUInteger)0, @"We should be at zero here..");
}

-(void)testGetWithRange
{
	NSData *d = [NSData dataWithBytes:"abc123" length:6];
	[data addData:d];
	NSData *d2 = [data getDataWithRange:NSMakeRange(2, 2)];
	STAssertTrue([[d subdataWithRange:NSMakeRange(2, 2)] isEqualToData:d2], @"Data is not the same!");
}

-(void)testPopWithRange
{
	NSData *d = [NSData dataWithBytes:"abc123" length:6];
	[data addData:d];
	NSData *d2 = [data popDataWithRange:NSMakeRange(2, 2)];
	char buf[2];
	[d2 getBytes:buf length:2];	
	GTMLoggerDebug(@"d2 = %c%c", buf[0], buf[1]);
	
	STAssertTrue([[d subdataWithRange:NSMakeRange(2, 2)] isEqualToData:d2], @"Data is not the same!");

	d2 = [data getData];
	char buf2[4];
	[d2 getBytes:buf2 length:4];
	GTMLoggerDebug(@"d2 = %c%c%c%c", buf2[0], buf2[1], buf2[2], buf2[3]);
	STAssertTrue([d2 isEqualToData:[NSData dataWithBytes:"ab23" length:4]], @"When popped we got something wierd...");
	
	STAssertEquals([data length], (NSUInteger)4, @"Brokeen.");
}

-(void)testReadOOB
{
	NSData *d = [NSData dataWithBytes:"abc123" length:6];
	[data addData:d];

	NSData *d2 = [data getDataWithRange:NSMakeRange(0, 10)];
	STAssertNil(d2, @"d2 needs to be null when we are trying to read to much.");
}

-(void)testAddWithoutExpanding
{
	data.shouldExpand = NO;
	char chars[200];
	memset (chars, 'b', 200);
	NSData *d = [NSData dataWithBytes:chars length:200];

	BOOL ret = [data addData:d];
	STAssertFalse(ret, @"Should be false since we don't expand this data!");
}

-(void)tearDown
{
	[data release];
}

@end
