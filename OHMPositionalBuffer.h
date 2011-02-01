//
//  OHMPositionalBuffer.h
//  OHMTagLib
//
//  Created by Tobias Hieta on 2011-01-03.
//  Copyright 2011 OHM Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OHMData.h"

@protocol OHMPositionalBufferSourceDelegate;
@protocol OHMPositionalBufferConsumerDelegate;


@interface OHMPositionalBuffer : NSObject {
	id sourceDelegate;
	id consumerDelegate;
	BOOL waitingForMoreData;
	OHMData *buffer;
	
}

-(id)init;
-(id)initWithData:(NSData*)data;
-(void)addData:(NSData*)data;

-(NSData*)getDataFromCurrentPosition:(UInt64)numBytes error:(NSError**)err;
-(NSData*)peekDataFromCurrentPosition:(UInt64)numBytes error:(NSError **)err;

-(BOOL)jumpPosition:(UInt64)numBytes;
-(void)getMoreData:(UInt64)length_;

@property (nonatomic, retain) id<OHMPositionalBufferSourceDelegate> sourceDelegate;
@property (nonatomic, retain) id<OHMPositionalBufferConsumerDelegate> consumerDelegate;
@property (nonatomic, readonly) UInt64 length;

@end

@protocol OHMPositionalBufferSourceDelegate<NSObject>

@optional
-(void)buffer:(OHMPositionalBuffer*)buf needMoreData:(UInt64)bytes;
-(void)buffer:(OHMPositionalBuffer*)buf jumpToPosition:(UInt64)position;
@end


@protocol OHMPositionalBufferConsumerDelegate

@optional
-(void)bufferHaveMoreData:(OHMPositionalBuffer*)buf;

@end

