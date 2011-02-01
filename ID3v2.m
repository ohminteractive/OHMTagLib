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
@synthesize delegate;
@synthesize buffer;

+(NSString*)name
{
    return @"ID3v2";
}

+(BOOL)isMine:(NSData*)tdata
{
    GTMLoggerDebug(@"trying data with length %d", [tdata length]);
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
	if ((self = [super init])) {
	}
	return self;
}

-(void)bufferHaveMoreData:(OHMPositionalBuffer *)buf
{
    /* let's do readMetadata again */
    GTMLoggerDebug(@"in id3v2 we got more data...");
    [self readMetadata];
}

-(void)readMetadata
{
    GTMLoggerDebug(@"running readMetadata in id3v2");
	if (!buffer) {
        NSError *error;
		GTMLoggerDebug(@"Error data was not set in parse first!");
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Request was not set before parse was called", 
                              NSLocalizedDescriptionKey, nil];
        error = [NSError errorWithDomain:kOHMTagLibErrorDomain code:kOHMTagLibErrorPropertyNotSet userInfo:dict];
        if ([delegate respondsToSelector:@selector(reader:readerError:)]) {
            [delegate reader:self readerError:error];
        }
        return;
	}
    
    NSData *data = [self.buffer getDataFromCurrentPosition:10 error:nil];
    if ([data length] < 10) {
        GTMLoggerDebug(@"not enough data here...");
        return; /* needMore should have been called */
    }
	
	xmms_id3v2_header_t header;
	unsigned char header_data[10];
	[data getBytes:&header_data length:10];
	
	if (xmms_id3v2_is_header (header_data, &header)) {
        
        data = [self.buffer getDataFromCurrentPosition:header.len - 10 error:nil];
        if ([data length] < (header.len - 10)) {
            GTMLoggerDebug(@"not enough data when fetching the whole frame expected %d got %d", header.len -10, [data length]);
            return;
        }
        
        OHMTagLibMetadata *metadata = [[[OHMTagLibMetadata alloc] init] autorelease];
        unsigned char *buf = malloc (header.len - 10);
        [data getBytes:buf length:header.len - 10];
			
        NSError *parserError;
        GTMLoggerDebug(@"running parser");
        if (!xmms_id3v2_parse (metadata, buf, &header, &parserError)) {
            GTMLoggerDebug(@"error!");
            if ([delegate respondsToSelector:@selector(reader:readerError:)]) {
                [delegate reader:self readerError:parserError];
            }
            return;
        }
        
        GTMLoggerDebug(@"done!");
        
        if ([delegate respondsToSelector:@selector(reader:gotMetadata:)]) {
            [delegate reader:self gotMetadata:metadata];
        }
        
        return;
	}
    
    NSError *_ohmError;
    NSDictionary *_errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"No id3v2 header found! ", 
                                NSLocalizedDescriptionKey, nil];
    _ohmError = [NSError errorWithDomain:kOHMTagLibErrorDomain code:kOHMTagLibErrorMetadataParser userInfo:_errorDict];
    if ([delegate respondsToSelector:@selector(reader:readerError:)]) {
        [delegate reader:self readerError:_ohmError];
    }
    
	return;
}

-(void)dealloc
{
    [buffer release];
    [delegate release];
	[super dealloc];
}

@end
