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
#import "OHMTagLibErrorCodes.h"

@implementation ID3v2
@synthesize name;
@synthesize request;


+(BOOL)isMine:(NSData*)tdata
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
		name = @"id3v2";
	}
	return self;
}

-(OHMTagLibMetadata*)parse:(NSError**)error
{
	if (!request.data) {
		NSLog(@"Error data was not set in parse first!");
		if (error) {
			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Request was not set before parse was called", 
								  NSLocalizedDescriptionKey, nil];
			*error = [NSError errorWithDomain:kOHMTagLibErrorDomain code:kOHMTagLibErrorPropertyNotSet userInfo:dict];
		}
		return nil;
	}
	
	if ([request.data length] < 10) {
		[request needMoreData:10 - [request.data length]];
		return nil;
	}

	xmms_id3v2_header_t header;
	unsigned char header_data[10];
	[request.data getBytes:&header_data length:10];
	
	if (xmms_id3v2_is_header (header_data, &header)) {
		if ([request.data length] < (header.len + 10)) {
			[request needMoreData:(header.len + 10) - [request.data length]];
			return nil; /* you need to call me again ... */
		} else {
			OHMTagLibMetadata *metadata = [[[OHMTagLibMetadata alloc] init] autorelease];
			unsigned char *buf = malloc (header.len);
			[request.data getBytes:buf range:NSMakeRange(10, header.len)];
			
			NSError *parserError;
			if (!xmms_id3v2_parse (metadata, buf, &header, &parserError)) {
				if (error) {
					*error = parserError;
				}
				return nil;
			}
			
			return metadata;
		}
		
	}
	
	if (error) {
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"File doesn't contain a id3v2 header!", NSLocalizedDescriptionKey, nil];
		*error = [NSError errorWithDomain:kOHMTagLibErrorDomain code:kOHMTagLibErrorMetadataParser userInfo:dict];
	}
	
	return nil;
}

-(void)dealloc
{
	[request release];
	[super dealloc];
}

@end
