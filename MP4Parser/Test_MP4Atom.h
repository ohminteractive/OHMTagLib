//
//  Test_MP4Atom.h
//  OHMTagLib
//
//  Created by Tobias Hieta on 2010-12-29.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMSenTestCase.h"
//#import "application_headers" as required

#import "OHMPositionalBuffer.h"

@interface Test_MP4Atom : GTMTestCase<OHMPositionalBufferSourceDelegate> {
	NSData *fileData;
}

-(void)testParseAtomHead;

@end
