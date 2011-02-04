//
//  MP4.m
//  OHMTagLib
//
//  Created by Tobias Hieta on 2010-12-20.
//  Copyright 2010 OHM Interactive. All rights reserved.
//

#import "MP4.h"
#import "OHMTagLibErrorCodes.h"
#import "GTMLogger.h"

@implementation MP4

@synthesize buffer;
@synthesize delegate;

+(NSString*)name
{
    return @"MP4";
}

-(id)init
{
	if ((self = [super init])) {
        parser = [MP4Parser new];
	}
	return self;
}

-(void)parser:(MP4Parser *)parser doneWithMetadata:(OHMTagLibMetadata *)metadata
{
    if ([delegate respondsToSelector:@selector(reader:gotMetadata:)]) {
        [delegate reader:self gotMetadata:metadata];
    }
}

-(void)bufferHaveMoreData:(OHMPositionalBuffer *)buf
{
    GTMLoggerDebug(@"Got more data to the MP4Parser");
    [parser parseAtoms];
}

-(void)readMetadata
{
    parser.delegate = self;
    parser.readBuffer = buffer;
    [parser parseAtoms];
}

+(BOOL)isMine:(NSData *)data
{
    if ([data length] > 8) {
        MP4Atom *atom = [MP4Atom getAtomFromData:data error:nil];
        if (atom && atom.type == kOHMMP4AtomFTYP) {
            return YES;
        } else {
            return NO;
        }
    }
    return NO;
}

- (void)dealloc {
    [delegate release];
    [parser release];
    [buffer release];
    [super dealloc];
}

@end
