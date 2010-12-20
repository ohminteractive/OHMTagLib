//
//  clitest.m
//  OHMTagLib
//
//  Created by Tobias Hieta on 2010-12-13.
//  Copyright 2010 OHM Interactive. All rights reserved.
//

#import "OHMTagLib.h"

@interface MyTest : NSObject<OHMTagLibMetadataRequestDelegate>
@end

@implementation MyTest

-(void)test:(NSData*)data
{
	OHMTagLib *taglib = [OHMTagLib new];
	OHMTagLibMetadataRequest *req = [OHMTagLibMetadataRequest new];
	req.data = data;
	req.delegate = self;
	[taglib addMetadataRequest:req];
	
}

-(void)metadataRequest:(OHMTagLibMetadataRequest *)request gotMetadata:(OHMTagLibMetadata *)metadata
{
	NSLog(@"We have new metadata!");
	NSLog(@"artist = %@ | album = %@ | title = %@", metadata.artist, metadata.album, metadata.title);
}

-(void)metadataRequest:(OHMTagLibMetadataRequest *)request parserError:(NSError *)error
{
	NSLog(@"Error when parsing metadata! %@", [error localizedDescription]);
}

-(void)metadataRequest:(OHMTagLibMetadataRequest *)request needMoreData:(int)bytes
{
	NSLog(@"metadata needs more data: %d!", bytes);
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