//
//  OHMTagLib.m
//  OHMTagLib
//
//  Created by Tobias Hieta on 2010-12-13.
//  Copyright 2010 OHM Interactive. All rights reserved.
//

#import "OHMTagLib.h"
#import "ID3v2.h"
#import "MP4.h"

@implementation OHMTagLib

@synthesize delegate;

-(id) init
{
	if (self = [super init]) {
		_readers = [[NSArray alloc] initWithObjects:[ID3v2 class], [MP4 class], nil];
		_operationQueue = [NSOperationQueue new];
		NSLog(@"OHMTagLib init!");
	}
	return self;
}

-(BOOL)canHandleData:(NSData*)data
{
	for (Class reader in _readers) {
		if ([reader isMine:data]) {
			return YES;
		}
	}
	return NO;
}

-(void)addMetadataRequest:(OHMTagLibMetadataRequest*)request
{
	for (Class reader in _readers) {
		if ([reader isMine:request.data]) {
			id r = [reader new];
			request.reader = r;
			[request parseMetadata];
			return;
		}
	}
}

-(void)dealloc
{
	[super dealloc];
}

@end
