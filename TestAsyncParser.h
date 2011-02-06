//
//  TestAsyncParser.h
//  OHMTagLib
//
//  Created by Tobias Hieta on 2011-02-06.
//  Copyright 2011 OHM Interactive. All rights reserved.
//

#import "GTMSenTestCase.h"
#import <Foundation/Foundation.h>
#import "OHMTagLib.h"

@interface TestAsyncParser : GTMTestCase<OHMTagLibMetadataRequestDelegate> {
    OHMTagLib *tagLib;
    NSData *testData;
    BOOL done;
}

@end
