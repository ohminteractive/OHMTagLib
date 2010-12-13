//
//  ID3v2.m
//  OHMTagLib
//
//  Created by Tobias Hieta on 2010-12-13.
//  Copyright 2010 OHM Interactive. All rights reserved.
//



#import "ID3v2.h"
#import "OHMTagLibMetadata.h"
#import "xmms2_id3v2.h"

@implementation ID3v2
@synthesize delegate;
@synthesize data;


-(BOOL)isMine:(NSData*)tdata
{
	if ([tdata length] < 10) {
		return NO;
	}
	
	xmms_id3v2_header_t header;
	unsigned char header_data[10];
	[tdata getBytes:&header_data length:10];
	
	return xmms_id3v2_is_header(header_data, &header);
}

-(id)init
{
	if (self = [super init]) {
	}
	return self;
}

-(NSString*)name
{
	return @"id3v2";
}

-(OHMTagLibMetadata*)parse
{
	if (!data) {
		NSLog(@"Error data was not set in parse first!");
		return nil;
	}

	xmms_id3v2_header_t header;
	unsigned char header_data[10];
	[data getBytes:&header_data length:10];
	
	if (xmms_id3v2_is_header (header_data, &header)) {
		if ([data length] < header.len) {
			NSLog(@"Need more data! missing %d bytes", header.len - [data length]);
			/* TODO */
		} else {
			
			OHMTagLibMetadata *metadata = [[OHMTagLibMetadata alloc] init];
			unsigned char *buf = malloc (header.len);
			[data getBytes:buf range:NSMakeRange(10, header.len)];
			
			xmms_id3v2_parse (metadata, buf, &header);
			
			return metadata;
		}
		
	}
	
	return nil;
}

@end
