//
//  TestOHMTagLib.h
//  OHMTagLib
//
//  Created by Tobias Hieta on 2011-01-27.
//  Copyright 2011 OHM Interactive. All rights reserved.
//

#import "GTMSenTestCase.h"
#import <UIKit/UIKit.h>
#import "OHMTagLib.h"
#import "GTMLogger.h"

@interface TestOHMTagLib : GTMTestCase<OHMTagLibMetadataRequestDelegate> {
    BOOL haveMetaData;
    OHMTagLib *tagLib;
}

@end
