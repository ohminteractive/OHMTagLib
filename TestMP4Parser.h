//
//  TestMP4Parser.h
//  OHMTagLib
//
//  Created by Tobias Hieta on 2011-01-19.
//  Copyright 2011 OHM Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMSenTestCase.h"
#import "MP4Parser.h"

@interface TestMP4Parser : GTMTestCase<MP4ParserDelegate> {
@private
    MP4Parser *parser;
    NSData *fileData;
}

@end
