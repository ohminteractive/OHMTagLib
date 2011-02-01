//
//  OHMTagLibMetadataRequest.h
//  DropPlay
//
//  Created by Tobias Hieta on 2010-12-17.
//  Copyright 2010 OHM Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OHMTagLibMetadata.h"
#import "OHMPositionalBuffer.h"

@class OHMTagLibMetadataRequest;

#import "OHMTagLibReader.h"

@protocol OHMTagLibMetadataRequestDelegate

-(void)metadataRequest:(OHMTagLibMetadataRequest*)request needMoreData:(int)bytes;
-(void)metadataRequest:(OHMTagLibMetadataRequest*)request jumpBytes:(int)bytes;
-(void)metadataRequest:(OHMTagLibMetadataRequest*)request gotMetadata:(OHMTagLibMetadata*)metadata;
-(void)metadataRequest:(OHMTagLibMetadataRequest*)request readError:(NSError*)error;

@end


@interface OHMTagLibMetadataRequest : NSObject<OHMPositionalBufferSourceDelegate,OHMTagLibReaderDelegate> {
	id userInfo;
	id delegate;
    OHMPositionalBuffer *buffer;
	id<OHMTagLibReader> reader;
	
@private
	int waitingForBytes;
}

@property (nonatomic, retain) id userInfo;
@property (nonatomic, retain) OHMPositionalBuffer *buffer;

@property (nonatomic, retain) id<OHMTagLibMetadataRequestDelegate> delegate;
@property (nonatomic, retain) id<OHMTagLibReader> reader;

-(id)init;
-(void)readMetadata;

@end
