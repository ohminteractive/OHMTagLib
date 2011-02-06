//
//  TestAsyncParser.m
//  OHMTagLib
//
//  Created by Tobias Hieta on 2011-02-06.
//  Copyright 2011 OHM Interactive. All rights reserved.
//

#import "TestAsyncParser.h"
#import "GTMLogger.h"

@implementation TestAsyncParser

-(void)setUp
{
    tagLib = [OHMTagLib new];
    testData = [NSData dataWithContentsOfFile:@"testdata/testm4a2.m4a"];
}

-(void)metadataRequest:(OHMTagLibMetadataRequest *)request jumpBytes:(int)bytes
{
    request.position += bytes;
}

-(void)addDataToRequest:(NSTimer*)timer
{
    
    GTMLoggerDebug(@"In addDataToRequest");
    OHMTagLibMetadataRequest *req = [timer.userInfo objectForKey:@"request"];
    int bytes = MAX([[timer.userInfo objectForKey:@"bytes"] intValue], 1024);
    GTMLoggerDebug(@"adding %d bytes to the request", bytes);
    [req.buffer addData:[testData subdataWithRange:NSMakeRange(req.position, bytes)]];
    req.position += bytes;
}

-(void)metadataRequest:(OHMTagLibMetadataRequest *)request needMoreData:(int)bytes
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:request, @"request", [NSNumber numberWithInt:bytes], @"bytes", nil];
    NSTimer *time = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(addDataToRequest:) userInfo:dict repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:time forMode:NSDefaultRunLoopMode];
}

-(void)metadataRequest:(OHMTagLibMetadataRequest *)request readError:(NSError *)error
{
    
}

-(void)metadataRequest:(OHMTagLibMetadataRequest *)request gotMetadata:(OHMTagLibMetadata *)metadata
{
    done = YES;
}

-(void)testAsyncParser
{
    OHMTagLibMetadataRequest *request = [OHMTagLibMetadataRequest new];
    request.delegate = self;
    [request.buffer addData:[testData subdataWithRange:NSMakeRange(0, 4096)]];
    request.position = 4096;
    
    [tagLib readMetadata:request];

    done = NO;
    while (!done) {
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
}

-(void)tearDown
{
    [tagLib release];
}


@end
