//
//  TestOHMTagLib.m
//  OHMTagLib
//
//  Created by Tobias Hieta on 2011-01-27.
//  Copyright 2011 OHM Interactive. All rights reserved.
//

#import "TestOHMTagLib.h"
#import "OHMTagLib.h"

@implementation TestOHMTagLib

-(void)setUp
{
    tagLib = [OHMTagLib new];
}

-(void)metadataRequest:(OHMTagLibMetadataRequest *)request jumpBytes:(int)bytes
{
}

-(void)metadataRequest:(OHMTagLibMetadataRequest *)request needMoreData:(int)bytes
{
    GTMLoggerDebug(@"metadataRequest:needMoreData:%d", bytes);
}

-(void)metadataRequest:(OHMTagLibMetadataRequest *)request readError:(NSError *)error
{
}

-(void)metadataRequest:(OHMTagLibMetadataRequest *)request gotMetadata:(OHMTagLibMetadata *)metadata
{
    GTMLoggerDebug(@"got metadata %@", metadata);
    haveMetaData = YES;
    GTMLoggerDebug(@"done");
}

-(void)testMP3
{
    OHMTagLibMetadataRequest *request = [OHMTagLibMetadataRequest new];
    request.delegate = self;
    
    NSData *data = [NSData dataWithContentsOfFile:@"testdata/testmp3.mp3"];
    if (!data || [data length] == 0) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"testmp3" ofType:@"mp3"];
        STAssertNotNil(filePath, @"we should have a filepath here!");
        data = [NSData dataWithContentsOfFile:filePath];
    }

    haveMetaData = NO;
    [request.buffer addData:data];
    
    [tagLib readMetadata:request];
    
    while (!haveMetaData) {
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        GTMLoggerDebug(@"one loop in the mainloop!");
    }
    
    STAssertTrue(haveMetaData, @"We should have the metadata by now...");
}

-(void)testMP4
{
    OHMTagLibMetadataRequest *request = [OHMTagLibMetadataRequest new];
    request.delegate = self;
    
    NSData *data = [NSData dataWithContentsOfFile:@"testdata/testm4a.m4a"];
    if (!data || [data length] == 0) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"testm4a" ofType:@"m4a"];
        STAssertNotNil(filePath, @"we should have a filepath here!");
        data = [NSData dataWithContentsOfFile:filePath];
    }
    
    haveMetaData = NO;
    [request.buffer addData:data];
    
    [tagLib readMetadata:request];
    
    while (!haveMetaData) {
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        GTMLoggerDebug(@"one loop in the mainloop!");
    }
    
    STAssertTrue(haveMetaData, @"We should have the metadata by now...");
}

@end
