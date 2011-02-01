//
//  TestPositionalBuffer.h
//  OHMTagLib
//
//  Created by Tobias Hieta on 2011-01-05.
//  Copyright 2011 Purple Scout. All rights reserved.
//

#import "GTMSenTestCase.h"
#import "OHMPositionalBuffer.h"

@interface TestPositionalBuffer : GTMTestCase<OHMPositionalBufferSourceDelegate,OHMPositionalBufferConsumerDelegate> {
	OHMPositionalBuffer *buffer;
	BOOL needMoreData;
	BOOL jumpToPos;
	BOOL consumerHaveMoreData;
}

-(void)testAdd;

@end
