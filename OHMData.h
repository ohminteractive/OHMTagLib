//
//  OHMData.h
//  OHMTagLib
//
//  Created by Tobias Hieta on 2011-01-10.
//  Copyright 2011 OHM Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OHMData : NSObject {
	void *dataBuffer;
	NSUInteger dataBufferSize;
	NSUInteger dataBufferLength;
	BOOL shouldExpand;
}

-(id)initWithSize:(NSUInteger)size;
-(id)init; /* standard size */

-(BOOL)addData:(NSData*)data;
-(NSData*)getData;
//-(void)removeDataWithRange:(NSRange)range;
-(NSData*)getDataWithRange:(NSRange)range;

-(NSData*)popData;
-(NSData*)popDataWithRange:(NSRange)range;
-(void)removeAllData;

@property (nonatomic, assign) BOOL shouldExpand;
@property (nonatomic, readonly) NSUInteger freeSpace;
@property (nonatomic, readonly) NSUInteger length;
@property (nonatomic, readonly) NSUInteger dataSize;

@end
