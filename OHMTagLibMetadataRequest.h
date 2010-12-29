//
//  OHMTagLibMetadataRequest.h
//  DropPlay
//
//  Created by Tobias Hieta on 2010-12-17.
//  Copyright 2010 OHM Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OHMTagLibMetadata.h"

@class OHMTagLibMetadataRequest;

#import "OHMTagLibReader.h"

@protocol OHMTagLibMetadataRequestDelegate

-(void)metadataRequest:(OHMTagLibMetadataRequest*)request needMoreData:(int)bytes;
-(void)metadataRequest:(OHMTagLibMetadataRequest*)request gotMetadata:(OHMTagLibMetadata*)metadata;
-(void)metadataRequest:(OHMTagLibMetadataRequest*)request parserError:(NSError*)error;

@end


@interface OHMTagLibMetadataRequest : NSObject {
	id userInfo;
	id delegate;
	NSMutableData *data;
	id reader;
	
@private
	int waitingForBytes;
}

@property (nonatomic, retain) id userInfo;
@property (nonatomic, retain) id<OHMTagLibMetadataRequestDelegate> delegate;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) id<OHMTagLibReader> reader;

-(id)initWithData:(NSData*)data;
-(void)needMoreData:(int)bytes;
-(void)parseMetadata;

@end
