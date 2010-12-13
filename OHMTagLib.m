//
//  OHMTagLib.m
//  OHMTagLib
//
//  Created by Tobias Hieta on 2010-12-13.
//  Copyright 2010 OHM Interactive. All rights reserved.
//

#import "OHMTagLib.h"
#import "ID3v2.h"

@implementation OHMTagLib

@synthesize delegate;

-(id) init
{
	if (self = [super init]) {
		ID3v2 *reader = [ID3v2 new];
		reader.delegate = self;
		_readers = [NSArray arrayWithObjects:reader, nil];
		[reader release];
		NSLog(@"OHMTagLib init!");
	}
	return self;
}

-(BOOL)canHandleData:(NSData*)data
{
	for (id<OHMTagLibReader> reader in _readers) {
		if ([reader isMine:data]) {
			return YES;
		}
	}
	return NO;
}

-(OHMTagLibMetadata*)getMetadataFromData:(NSData*)data
{
	for (id<OHMTagLibReader> reader in _readers) {
		if ([reader isMine:data]) {
			NSLog(@"Reader %@ is handling this data", [reader name]);
			reader.data = data;
			return [reader parse];
		}
	}
	return nil;
}

-(NSData*)needMoreData:(NSInteger)bytes
{
	return [delegate needMoreData:bytes];
}

-(void)dealloc
{
	[super dealloc];
}

@end
