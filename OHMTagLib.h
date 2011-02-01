//
//  OHMTagLib.h
//  OHMTagLib
//
//  Created by Tobias Hieta on 2010-12-13.
//  Copyright 2010 OHM Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OHMTagLibMetadata.h"
#import "OHMTagLibDelegate.h"
#import "OHMTagLibReader.h"
#import "OHMTagLibMetadataRequest.h"

@interface OHMTagLib : NSObject {
	id delegate;
@private
	NSOperationQueue *_operationQueue;
	NSArray *_readers;
    BOOL useConcurrentSessions;
}

-(BOOL)canHandleData:(NSData *)data;
-(void)readMetadata:(OHMTagLibMetadataRequest*)request;

@property (assign, nonatomic) BOOL useConcurrentSessions;
@property (assign, nonatomic) id<OHMTagLibDelegate> delegate;

@end
