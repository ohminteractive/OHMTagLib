//
//  clitest.m
//  OHMTagLib
//
//  Created by Tobias Hieta on 2010-12-13.
//  Copyright 2010 OHM Interactive. All rights reserved.
//

#import "OHMTagLib.h"

@interface MyTest : NSObject<OHMTagLibDelegate>
@end

@implementation MyTest

-(void)test:(NSData*)data
{
	OHMTagLib *taglib = [OHMTagLib new];
	taglib.delegate = self;
	
	if ([taglib canHandleData:data]) {
		OHMTagLibMetadata *md = [taglib getMetadataFromData:data];
	} else {
		NSLog(@"can't handle this!");
	}
}

-(NSData*)needMoreData:(NSInteger)lenght
{
	return nil;
}

@end


int main(int argc, char *argv[])
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSLog(@"argc = %d", argc);
	if (argc != 2) {
		NSLog(@"Need a filename!");
		exit(-1);
	}
	
	NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithCString:argv[1]]];
	MyTest *test = [MyTest new];
	[test test:data];
	
	[pool release];
}