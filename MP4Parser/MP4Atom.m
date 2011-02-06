//
//  MP4Atom.m
//  OHMTagLib
//
//  Created by Tobias Hieta on 2010-12-29.
//  Copyright 2010 OHM Interactive. All rights reserved.
//

#import "MP4Atom.h"
#import "OHMTagLibErrorCodes.h"
#import "GTMLogger.h"

@implementation MP4Atom

@synthesize type, size, data;
@synthesize subatoms;

+(SInt32)getAtomSize:(NSData*)data_
{
    UInt32 a, b, c, d;
	UInt8 bf[4];

	[data_ getBytes:&bf range:NSMakeRange(0, 4)];
	a=(UInt8)bf[0];
	b=(UInt8)bf[1];
	c=(UInt8)bf[2];
	d=(UInt8)bf[3];
	
	SInt32 size = (a<<24) | (b<<16) | (c<<8) | d;
	
	if (size == 1) {
		GTMLoggerDebug(@"Size == 1 and this means that we have 64 bit size.");
	}
	
	return size;
}

struct atomTypes_t {
	int8_t a;
	int8_t b;
	int8_t c;
	int8_t d;
	UInt8 type_;
};

static struct atomTypes_t typeMap[] = {
    { 'f','t','y','p', kOHMMP4AtomFTYP },
	{ 'm','o','o','v', kOHMMP4AtomMOOV },
	{ 'm','e','t','a', kOHMMP4AtomMETA },
	{ kOHMMP4CopyrightSymbol,'n','a','m', kOHMMP4AtomTITLE },
	{ kOHMMP4CopyrightSymbol,'A','R','T', kOHMMP4AtomARTIST },
	{ kOHMMP4CopyrightSymbol,'a','l','b', kOHMMP4AtomALBUM },
	{ kOHMMP4CopyrightSymbol,'d','a','y', kOHMMP4AtomDATE },
	{ kOHMMP4CopyrightSymbol,'g','e','n', kOHMMP4AtomGENRE },
	{ 'u','d','t','a', kOHMMP4AtomUDAT },
	{ 'i','l','s','t', kOHMMP4AtomILST },
	{ 'd','a','t','a', kOHMMP4AtomDATA },
	{ 'c','p','i','l', kOHMMP4AtomCOMPILATION },
	{ 'p','c','s','t', kOHMMP4AtomPODCAST },
	{ 'u','k','n','o', kOHMMP4AtomUnknown },
	{ 0, 0, 0, 0, 0 },
};

+(UInt8)getAtomType:(NSData*)data_
{
	int8_t a, b, c, d;

	[data_ getBytes:&a range:NSMakeRange(4, 1)];
	[data_ getBytes:&b range:NSMakeRange(5, 1)];
	[data_ getBytes:&c range:NSMakeRange(6, 1)];
	[data_ getBytes:&d range:NSMakeRange(7, 1)];
	
	int i = 0;
	while (typeMap[i].a != 0) {
		struct atomTypes_t ty = typeMap[i];
		if (ty.a == a && ty.b == b && ty.c == c && ty.d == d) {
			return ty.type_;
		}
		
		i++;
	}

	return kOHMMP4AtomUnknown;
	
}

+(NSString*)getAtomNameFromType:(UInt32)type_
{
	int i = 0;
	
	while (typeMap[i].a != 0) {
		if (type_ == typeMap[i].type_) {
			return [NSString stringWithFormat:@"%c%c%c%c", typeMap[i].a, typeMap[i].b, typeMap[i].c, typeMap[i].d];
		}
		i++;
	}
	return @"Unknown";
}

+(MP4Atom*)getAtomFromData:(NSData*)data_ error:(NSError**)err_
{
	
	if ([data_ length] < 8) {
		if (err_) {
			*err_ = [NSError errorWithDomain:kOHMTagLibErrorDomain code:kOHMTagLibErrorNotEnoughData userInfo:nil];
		}
		return nil;
	}
		
	MP4Atom *atom = [[[MP4Atom alloc] init] autorelease];
	atom.size = [MP4Atom getAtomSize:data_];
	atom.type = [MP4Atom getAtomType:data_];
    
    char tmpBuf[8];
    [data_ getBytes:tmpBuf length:8];
    GTMLoggerDebug(@"%c %c %c %c %c %c %c %c", tmpBuf[0], tmpBuf[1], tmpBuf[2], tmpBuf[3], tmpBuf[4], tmpBuf[5], tmpBuf[6], tmpBuf[7]);
    
	GTMLoggerDebug(@"Got atom with size %d and type %@ (%d)", atom.size, atom.typeName, atom.type);
	
	return atom;
}

-(NSString*)typeName
{
	return [MP4Atom getAtomNameFromType:self.type];
}

@end
