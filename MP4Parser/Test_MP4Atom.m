//
//  Test_MP4Atom.m
//  OHMTagLib
//
//  Created by Tobias Hieta on 2010-12-29.
//  Copyright 2010 OHM Interactive. All rights reserved.
//

#import "Test_MP4Atom.h"
#import "MP4Atom.h"
#import "MP4Parser.h"

#import "GTMLogger.h"

@implementation Test_MP4Atom

-(void)setUp
{
}

-(void)testParseAtomHead
{
	char *atom = "\x00\x01\xce\x84\x6d\x6f\x6f\x76";
	MP4Atom *mAtom = [MP4Atom getAtomFromData:[NSData dataWithBytes:atom length:8] error:nil];
	STAssertEquals(mAtom.type, (UInt8)kOHMMP4AtomMOOV, @"This should be the MOOV atom");
	STAssertEquals(mAtom.size, (SInt32)118404, @"Size should be 118404");
}

-(void)testParseAtomWithCopyrightSymbol
{
	char *atom = "\x00\x00\x00\x27\xa9\x6e\x61\x6d";
	MP4Atom *mAtom = [MP4Atom getAtomFromData:[NSData dataWithBytes:atom length:8] error:nil];
	STAssertEquals(mAtom.type, (UInt8)kOHMMP4AtomTITLE, @"this is title atom.");
	STAssertEquals(mAtom.size, (SInt32)39, @"size should be 39");
}

-(void)tearDown
{
}

@end
