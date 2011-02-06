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
	OHMData *buffer;
}

-(id)init;
-(id)initWithData:(NSData*)data;
-(void)addData:(NSData*)data;

-(NSData*)getDataFromCurrentPosition:(NSUInteger)numBytes error:(NSError**)err;
-(NSData*)peekDataFromCurrentPosition:(NSUInteger)numBytes error:(NSError **)err;

-(BOOL)jumpPosition:(NSUInteger)numBytes;
-(void)getMoreData:(NSUInteger)length_;

@property (retain) id<OHMPositionalBufferSourceDelegate> sourceDelegate;
@property (retain) id<OHMPositionalBufferConsumerDelegate> consumerDelegate;
@property (readonly) NSUInteger length;

@end

@protocol OHMPositionalBufferSourceDelegate<NSObject>

@optional
-(void)buffer:(OHMPositionalBuffer*)buf needMoreData:(NSUInteger)bytes;
-(void)buffer:(OHMPositionalBuffer*)buf jumpToPosition:(NSUInteger)position;
@end


@protocol OHMPositionalBufferConsumerDelegate

@optional
-(void)bufferHaveMoreData:(OHMPositionalBuffer*)buf;

@end

