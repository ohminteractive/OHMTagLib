//
//  MP4Parser.h
//  OHMTagLib
//
//  Created by Tobias Hieta on 2010-12-29.
//  Copyright 2010 OHM Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OHMPositionalBuffer.h"
#import "OHMTagLibMetadata.h"
#import "MP4AtomTypes.h"


@class MP4Parser;

@protocol MP4ParserDelegate

-(void)parser:(MP4Parser*)parser doneWithMetadata:(OHMTagLibMetadata*)metadata;

@end

@interface MP4Parser : NSObject<OHMPositionalBufferConsumerDelegate> {
	BOOL done;
@private
	OHMPositionalBuffer *readBuffer;
	int nextAtom;
	OHMTagLibMetadata *metaData;
    id delegate;
}

-(void)parseAtoms;

@property (nonatomic, retain) id<MP4ParserDelegate> delegate;
@property (nonatomic, retain) OHMPositionalBuffer *readBuffer;
@property (nonatomic, readonly) BOOL done;

@end
