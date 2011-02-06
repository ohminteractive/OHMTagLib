//
//  TestPositionalBuffer.m
//  OHMTagLib
//
//  Created by Tobias Hieta on 2011-01-05.
//  Copyright 2011 OHM Interactive. All rights reserved.
//

#import "TestPositionalBuffer.h"


@implementation TestPositionalBuffer


-(void)setUp
{
	buffer = [OHMPositionalBuffer new];
	needMoreData = NO;
	jumpToPos = NO;
	consumerHaveMoreData = NO;
}

-(void)testAdd
{
	NSData *data = [NSData dataWithBytes:"abc123" length:6];
	[buffer addData:data];
	STAssertEquals(6U, [buffer length], @"Size should be 6 was %d!", [buffer length]);
}

-(void)testAddAndRead
{
	NSData *data = [NSData dataWithBytes:"abcd1234" length:8];
	[buffer addData:data];
	
	NSData *d1 = [buffer getDataFromCurrentPosition:2 error:nil];
	STAssertEquals(2U, [d1 length], @"Size mismatch!");
	STAssertEquals(6U, [buffer length], @"Size mismatch!");
	
	NSData *cmp = [NSData dataWithBytes:"ab" length:2];
	STAssertTrue([d1 isEqualToData:cmp], @"Data is not what I was expecting!");
	
	d1 = [buffer getDataFromCurrentPosition:6 error:nil];
	STAssertEquals(6U, [d1 length], @"Size mismatch!");
	STAssertEquals(0U, [buffer length], @"Size mismatch!");
	
	cmp = [NSData dataWithBytes:"cd1234" length:6];
	STAssertTrue([d1 isEqualToData:cmp], @"Data is not what I was expecting! d1 = %s", [d1 bytes]);
}

-(void)testReadOOB
{
	NSData *data = [NSData dataWithBytes:"abcd1234" length:8];
	[buffer addData:data];

	NSData *d1 = [buffer getDataFromCurrentPosition:10 error:nil];
	STAssertEquals((NSUInteger)8, [d1 length], @"Size mismatch!");
}

-(void)testReadEmpty
{
	NSData *d1 = [buffer getDataFromCurrentPosition:1 error:nil];
	STAssertNil(d1, @"We should get nil from here!");
}

-(void)buffer:(OHMPositionalBuffer *)buf needMoreData:(NSUInteger)bytes
{
	needMoreData = YES;
	STAssertEquals(1U, bytes, @"We expected to get just one more byte here!");
}

-(void)testGotNeedMoreData
{
	buffer.sourceDelegate = self;
	[buffer getDataFromCurrentPosition:1 error:nil];
	STAssertTrue(needMoreData, @"need more data was never called!");
}

-(void)testJump
{
	NSData *data = [NSData dataWithBytes:"abcd1234" length:8];
	[buffer addData:data];

	[buffer jumpPosition:3];
	STAssertEquals(5U, [buffer length], @"Buffer should be truncated to 5 bytes!");
	
	NSData *d1 = [buffer getDataFromCurrentPosition:5 error:nil];
	NSData *cmp = [NSData dataWithBytes:"d1234" length:5];
	
	STAssertTrue([d1 isEqualToData:cmp], @"The buffer should contain d1234 but contains %s", [d1 bytes]);
}

-(void)buffer:(OHMPositionalBuffer *)buf jumpToPosition:(NSUInteger)position
{
	STAssertEquals(2U, position, @"Expected to jump to position 2!");
	jumpToPos = YES;
}

-(void)testJumpDelegate
{
	NSData *data = [NSData dataWithBytes:"abcd1234" length:8];
	[buffer addData:data];
	
	buffer.sourceDelegate = self;

	[buffer jumpPosition:10];
	STAssertTrue(jumpToPos, @"jumpToPosition was never called from the buffer!");
}

-(void)bufferHaveMoreData:(OHMPositionalBuffer *)buf
{
	STAssertEqualObjects(buf, buffer, @"We didn't get our buffer!");
	STAssertEquals(8U, [buf length], @"Expected 8 bytes in buffer!");
	consumerHaveMoreData = YES;
}

-(void)testConsumerHaveData
{
	NSData *data = [NSData dataWithBytes:"abcd1234" length:8];
	[buffer addData:data];

	buffer.consumerDelegate = self;
	[buffer getDataFromCurrentPosition:10 error:nil];
	[buffer addData:data];
	STAssertTrue(consumerHaveMoreData, @"consumerHaveMoreData was never set");
}

-(void)testJumpReturnWithoutDelegate
{
	NSData *data = [NSData dataWithBytes:"abcd1234" length:8];
	[buffer addData:data];
	BOOL ret = [buffer jumpPosition:100];
	STAssertFalse(ret, @"We shouldn't be allowed to jump here!");
}

-(void)testJumpReturnWithDelegate
{
	buffer.sourceDelegate = self;
	BOOL ret = [buffer jumpPosition:2];
	STAssertTrue(ret, @"Since we have an delegate that responds we should be allowed to jump!");
}

-(void)testEmptyBufferAfterJump
{
	buffer.sourceDelegate = self;
	[buffer jumpPosition:2];
	STAssertEquals(0U, [buffer length], @"The buffer should be empty after a jump!");
}

-(void)testMoreDataAfterJump
{
	buffer.sourceDelegate = self;
	buffer.consumerDelegate = self;
	
	/* this should make sure that haveMoreDataAvailable is called when
	 * we add data to the buffer */
	[buffer jumpPosition:2];
	[buffer addData:[NSData dataWithBytes:"abc12345" length:8]];
	STAssertTrue(consumerHaveMoreData, @"haveMoreData never called!");
	
}

-(void)testPeekData
{
    [buffer addData:[NSData dataWithBytes:"abc123" length:6]];
    NSData *peek = [buffer peekDataFromCurrentPosition:3 error:nil];
    NSData *abc = [NSData dataWithBytes:"abc" length:3];
    STAssertTrue([abc isEqualToData:peek], @"Bah, something is wrong with peek...");
    STAssertEquals(6U, [buffer length], @"We should have 6 bytes left in the buffer");
}

-(void)tearDown
{
	[buffer release];
}


@end
