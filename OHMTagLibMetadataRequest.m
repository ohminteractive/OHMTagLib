//
//  OHMTagLibMetadataRequest.m
//  DropPlay
//
//  Created by Tobias Hieta on 2010-12-17.
//  Copyright 2010 OHM Interactive. All rights reserved.
//

#import "OHMTagLibMetadataRequest.h"
#import "GTMLogger.h"

@implementation OHMTagLibMetadataRequest

@synthesize userInfo;
@synthesize delegate;
@synthesize buffer;
@synthesize reader;
@synthesize position;

-(id)init
{
    if ((self = [super init])) {
        self.buffer = [OHMPositionalBuffer new];
        buffer.sourceDelegate = self;
    }
    
    return self;
}

-(void)buffer:(OHMPositionalBuffer *)buf needMoreData:(UInt64)bytes
{
    GTMLoggerDebug(@"metadatarequest needs more data");
    if ([delegate respondsToSelector:@selector(metadataRequest:needMoreData:)]) {
        [delegate metadataRequest:self needMoreData:bytes];
    }
}

-(void)buffer:(OHMPositionalBuffer *)buf jumpToPosition:(UInt64)position_
{
    GTMLoggerDebug(@"metadataRequest is jumping");
    if ([delegate respondsToSelector:@selector(metadataRequest:jumpBytes:)]) {
        [delegate metadataRequest:self jumpBytes:position_];
    }
}

-(void)reader:(id<OHMTagLibReader>)reader readerError:(NSError *)error
{
    if ([delegate respondsToSelector:@selector(metadataRequest:parserError:)]) {
        [delegate metadataRequest:self readError:error];
    }
}

-(void)reader:(id<OHMTagLibReader>)reader gotMetadata:(OHMTagLibMetadata *)metaData
{
    if ([delegate respondsToSelector:@selector(metadataRequest:gotMetadata:)]) {
        [delegate metadataRequest:self gotMetadata:metaData];
    }
}

-(void)readMetadata
{
	if (!reader) {
		GTMLoggerDebug(@"can't find parser ...");
        if ([delegate respondsToSelector:@selector(metadataRequest:readError:)]) {
            NSError *err = [NSError errorWithDomain:@"se.ohminteractive.taglib.error" code:1 userInfo:nil];
            [delegate metadataRequest:self readError:err];
        }

		return;
	}
    
    /* Forward the buffer to the reader */
    self.reader.buffer = buffer;
    buffer.consumerDelegate = self.reader;
    self.reader.delegate = self;
    [self.reader readMetadata];
}

@end
