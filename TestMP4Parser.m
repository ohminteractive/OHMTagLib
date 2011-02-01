//
//  TestMP4Parser.m
//  OHMTagLib
//
//  Created by Tobias Hieta on 2011-01-19.
//  Copyright 2011 OHM Interactive. All rights reserved.
//

#import "TestMP4Parser.h"
#import "GTMLogger.h"

@implementation TestMP4Parser

-(void)setUp
{
    parser = [MP4Parser new];
}

-(void)buffer:(OHMPositionalBuffer *)buf needMoreData:(UInt64)bytes
{
    if (fileData) {
        [buf addData:fileData];
        fileData = nil;

        /* always call parseAtoms after we have added more data */
        [parser parseAtoms];
    }
    
    GTMLoggerDebug(@"We sent data to the parser");
}

-(void)parser:(MP4Parser *)parser doneWithMetadata:(OHMTagLibMetadata *)metaData
{
    if (metaData == nil || metaData.artist == nil) {
        GTMLoggerDebug(@"korv!");
    }
    GTMLoggerDebug(@"We got metadata! '%@'", metaData.artist);
    STAssertTrue([metaData.artist isEqualToString:@"Edge of Dawn"], @"korv");
    STAssertTrue([metaData.album isEqualToString:@"Anything That Gets You Through the Night"], @"korv");
    STAssertTrue([metaData.title isEqualToString:@"Beyond the Gate"], @"korv");
    STAssertTrue([metaData.year isEqualToString:@"2010-05-21"], @"korv");
}

-(void)testParseFullFile
{
    GTMLoggerDebug(@"running parseFullFile..");
	fileData = [NSData dataWithContentsOfFile:@"testdata/testm4a.m4a"];
    STAssertNotNil(fileData, @"no testdata");
	parser.delegate = self;

    [parser.readBuffer addData:fileData];
    GTMLoggerDebug(@"Going into the parser");
	[parser parseAtoms];
    GTMLoggerDebug(@"Done with parseAtoms");
}

-(void)tearDown
{
    [parser release];
}

@end
