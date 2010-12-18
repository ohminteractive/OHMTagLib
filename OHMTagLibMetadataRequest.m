//
//  OHMTagLibMetadataRequest.m
//  DropPlay
//
//  Created by Tobias Hieta on 2010-12-17.
//  Copyright 2010 OHM Interactive. All rights reserved.
//

#import "OHMTagLibMetadataRequest.h"


@implementation OHMTagLibMetadataRequest
@synthesize userInfo;
@synthesize delegate;
@synthesize data;
@synthesize reader;

-(id)initWithData:(NSData *)aData
{
	if (self = [super init]) {
		self.data = aData;
	}
	
	return self;
}

-(void)needMoreData:(int)bytes
{
	if ([delegate respondsToSelector:@selector(metadataRequest:needMoreData:)]) {
		[delegate metadataRequest:self needMoreData:bytes];
		waitingForBytes = bytes;
	}
}

-(void)tryParse
{
	NSError *error;
	OHMTagLibMetadata *metaData = [reader parse:&error];
	if (metaData) {
		if ([delegate respondsToSelector:@selector(metadataRequest:gotMetadata:)]) {
			[delegate metadataRequest:self gotMetadata:metaData];
		}
	} else if (waitingForBytes) {
		return;
	} else {
		if ([delegate respondsToSelector:@selector(metadataRequest:parserError:)]) {
			[delegate metadataRequest:self parserError:error];
		}
	}	
}

-(BOOL)addMoreData:(NSData*)moreData
{
	[data appendData:moreData];
	waitingForBytes -= [moreData length];
	NSLog(@"wait %d", waitingForBytes);
	if (waitingForBytes > 0) {
		return NO;
	} else {
		[self tryParse];
		return YES;
	}
}

-(void)parseMetadata
{
	if (!reader) {
		NSLog(@"can't find parser ...");
		return;
	}
	
	self.reader.request = self;
	
	[self tryParse];
}

@end
