//
//  TestOHMRingBuffer.h
//  OHMTagLib
//
//  Created by Tobias Hieta on 2011-02-07.
//  Copyright 2011 OHM Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OHMRingBuffer.h"
#import "GTMSenTestCase.h"

@interface TestOHMRingBuffer : GTMTestCase {
    OHMRingBuffer *buffer;
    BOOL ready;
}

@end
