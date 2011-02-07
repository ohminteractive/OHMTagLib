//
//  OHMRingBuffer.h
//  OHMTagLib
//
//  Created by Tobias Hieta on 2011-02-07.
//  Copyright 2011 OHM Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OHMData.h"


@interface OHMRingBuffer : NSObject {
    NSUInteger storageSize;
    
    @private
    NSCondition *freeCondition;
    NSCondition *usedCondition;
    OHMData *storage;
}

@property (readonly) NSUInteger storageSize;
@property (readonly) NSUInteger freeSpace;
@property (readonly) NSUInteger usedSpace;
@property (readonly) BOOL canWrite;
@property (readonly) BOOL canRead;

-(id)initWithStorageSize:(NSUInteger)size;
-(NSData*)popData:(NSUInteger)bytes waitForData:(BOOL)wait;
-(BOOL)addData:(NSData*)data waitForFreeSpace:(BOOL)wait;
-(void)removeAllData;

@end
