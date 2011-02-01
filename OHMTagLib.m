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
@synthesize useConcurrentSessions;

-(id) init
{
	if ((self = [super init])) {
		_readers = [[NSArray alloc] initWithObjects:[ID3v2 class], [MP4 class], nil];
		_operationQueue = [NSOperationQueue new];
        _operationQueue.name = @"readMetadataQueue";
        self.useConcurrentSessions = YES;
		GTMLoggerDebug(@"OHMTagLib init!");
	}
	return self;
}

-(Class)getReaderForData:(NSData*)data
{
    for (Class reader in _readers) {
        GTMLoggerDebug(@"Trying reader %@", [reader name]);
        if ([reader isMine:data]) {
            return reader;
        }
    }
    return nil;
}

-(BOOL)canHandleData:(NSData*)data
{
    Class reader = [self getReaderForData:data];
    return reader != nil;
}

-(void)readMetadata:(OHMTagLibMetadataRequest*)request
{
    /* "borrow" 10 bytes of data and see if they match any reader plugin */
    NSData *data = [request.buffer peekDataFromCurrentPosition:10 error:nil];
    if ([data length] != 10) {
        GTMLoggerDebug(@"didn't get 10 bytes from peek!");
        return;
    }
    Class reader = [self getReaderForData:data];
    if (!reader) {
        GTMLoggerDebug(@"No reader, big big problem");
        return;
    }
    
    request.reader = [reader new];
    if (self.useConcurrentSessions) {
        [_operationQueue addOperationWithBlock:^{
            [request readMetadata];
        }];
    } else {
        [request readMetadata];
    }
}

-(void)dealloc
{
	[super dealloc];
}

@end
