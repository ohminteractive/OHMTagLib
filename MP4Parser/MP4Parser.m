//
//  MP4Parser.m
//  OHMTagLib
//
//  Created by Tobias Hieta on 2010-12-29.
//  Copyright 2010 OHM Interactive. All rights reserved.
//

#import "MP4Parser.h"
#import "MP4Atom.h"
#import "GTMLogger.h"
#import "OHMTagLibMetadata.h"

#define kOHMMP4AtomHeaderSize 8
#define kOHMMP4AtomSizeOfDataHeader 8

@implementation MP4Parser

@synthesize done;
@synthesize delegate;
@synthesize readBuffer;

-(id)init
{
    if ((self = [super init])) {
        metaData = [OHMTagLibMetadata new];
        nextAtom = kOHMMP4AtomUnknown;
        done = NO;
        GTMLoggerDebug(@"MP4Parser inited...");
    }
    return self;
}

-(MP4Atom*)getAtom:(int)atomType
{
	GTMLoggerDebug(@"Searching for atom: %@", [MP4Atom getAtomNameFromType:atomType]);
	while (YES) {
		
		if ([readBuffer length] < kOHMMP4AtomHeaderSize) {
			/* just request a whole new HEADER */
			[readBuffer getMoreData:kOHMMP4AtomHeaderSize];
            GTMLoggerDebug(@"Not enough data! %d", [readBuffer length]);
			return nil;
		}
		
		NSData *dataToSearch = [readBuffer getDataFromCurrentPosition:kOHMMP4AtomHeaderSize error:nil];
		if ([dataToSearch length] != kOHMMP4AtomHeaderSize) {
			GTMLoggerError(@"Whoopise, between here and before we have lost bytes?");
			return nil;
		}
		
		NSError *err;
		MP4Atom	*atom = [MP4Atom getAtomFromData:dataToSearch error:&err];
		if (!atom) {
			GTMLoggerDebug(@"Failed to get atom!");
			return nil;
		}
				
		if (atom.type == atomType) {
			GTMLoggerDebug(@"Found atom!");
			return atom;
		} else {
			GTMLoggerDebug(@"Jumping to pos %d", atom.size - kOHMMP4AtomHeaderSize);
			[readBuffer jumpPosition:atom.size - kOHMMP4AtomHeaderSize];
		}
	}
	
	return nil;
	
}

-(NSString*)copyAtomDataString:(OHMPositionalBuffer*)buf
{
    GTMLoggerDebug(@"Getting data value");
	MP4Atom *data = [MP4Atom getAtomFromData:[buf getDataFromCurrentPosition:kOHMMP4AtomHeaderSize error:nil] error:nil];
	if (data.type != kOHMMP4AtomDATA) {
		GTMLoggerDebug(@"We where looking for a data atom here...");
		return nil;
	}
	
    [buf getDataFromCurrentPosition:kOHMMP4AtomSizeOfDataHeader error:nil]; /* skip crap */
    NSData *value = [buf getDataFromCurrentPosition:data.size-(kOHMMP4AtomHeaderSize+kOHMMP4AtomSizeOfDataHeader) error:nil];
    if ([value length] != (data.size-(kOHMMP4AtomHeaderSize+kOHMMP4AtomSizeOfDataHeader))) {
        GTMLoggerDebug(@"We got the wrong number of bytes?");
    }
    
    char tmp[4];
    [value getBytes:tmp length:4];
    GTMLoggerDebug(@"%c %c %c %c", tmp[0], tmp[1], tmp[2], tmp[3]);
    
    GTMLoggerDebug(@"Coverting string...%s", [value bytes]);
	NSString *dta = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];//[NSString stringWithCharacters:[value bytes] length:[value length]];
	return dta;
}

-(BOOL)parseMeta:(int)atomSize
{
	BOOL metaDone = NO;
	if ([readBuffer length] < atomSize) {
        GTMLoggerDebug(@"Waiting for more data in the parseMeta function");
        [readBuffer getMoreData:atomSize - [readBuffer length]];
        return NO;
    }
    
    NSData *d = [readBuffer getDataFromCurrentPosition:atomSize error:nil];
    if ([d length] != atomSize) {
        GTMLoggerDebug(@"Problem, was expecting %d, but got %d", atomSize, [d length]);
        return NO;
    }
		
	OHMPositionalBuffer *buf = [OHMPositionalBuffer new];
	[buf addData:d];
	
	while (!metaDone) {
		MP4Atom *atom = [MP4Atom getAtomFromData:[buf getDataFromCurrentPosition:kOHMMP4AtomHeaderSize error:nil] error:nil];
        if (atom.size > [buf length]) {
            GTMLoggerDebug(@"Crash and burn...");
            metaDone = YES;
        }
        
        NSString *dataString = nil;
        if (atom.type == kOHMMP4AtomALBUM ||
            atom.type == kOHMMP4AtomARTIST ||
            atom.type == kOHMMP4AtomTITLE ||
            atom.type == kOHMMP4AtomDATE) {
            
            /* all these types have a dataString atom as next
             * atom in the list. Let's extract it here since it
             * returns a newly alloced string */
            dataString = [self copyAtomDataString:buf];
        }

		switch (atom.type) {
			case kOHMMP4AtomARTIST:
                metaData.artist = dataString;
                break;
			case kOHMMP4AtomALBUM:
                metaData.album = dataString;
				break;
			case kOHMMP4AtomTITLE:
				metaData.title = dataString;
				break;
			case kOHMMP4AtomDATE:
				metaData.year = dataString;
				break;
			default:
				[buf jumpPosition:atom.size - kOHMMP4AtomHeaderSize];
				break;
		}
        
        /* remember to not leak memory */
        if (dataString) {
            [dataString release];
        }
        
        GTMLoggerDebug(@"buffer length = %d", [buf length]);
        
        if ([buf length] < kOHMMP4AtomHeaderSize) {
            metaDone = YES;
            GTMLoggerDebug(@"artist = %@, album = %@, year = %@, title = %@", 
                           metaData.artist,
                           metaData.album,
                           metaData.year,
                           metaData.title);
        }
	}
    [buf release];
    
    if (metaDone) {
        return YES;
    } else {
        return NO;
    }
}

-(void)parseAtoms
{
    GTMLoggerDebug(@"in parseAtoms");
    if (done) {
        return;
    }
    
	if (nextAtom == kOHMMP4AtomUnknown) {
		nextAtom = kOHMMP4AtomMOOV;
	}
	
    if (nextAtom != -1) {
        MP4Atom *atom = [self getAtom:nextAtom];
        if (!atom) {
            GTMLoggerDebug(@"no atom, we need to wait for data...");
            return;
        }
	
        if (atom.type != nextAtom) {
            GTMLoggerError(@"getAtom returned the wrong type");
            return;
        }
	
        switch (atom.type) {
            case kOHMMP4AtomMOOV:
                nextAtom = kOHMMP4AtomUDAT;
                break;
            case kOHMMP4AtomUDAT:
                nextAtom = kOHMMP4AtomMETA;
                break;
            case kOHMMP4AtomMETA:
                {
                    /* skip some crap */
                    [readBuffer getDataFromCurrentPosition:4 error:nil];
				
                    nextAtom = kOHMMP4AtomILST;
                    break;
                }
            case kOHMMP4AtomILST:
			{
                nextAtom = -1;
                iLSTSize = atom.size;
                break;
			}
            default:
                GTMLoggerError(@"Unexpected atom!");
                break;
        }
    }else {
        GTMLoggerDebug(@"nextAtom == -1, let's parseMeta data");
        if ([self parseMeta:iLSTSize]) {
            done = YES;
            GTMLoggerDebug(@"We are done with metadata.. let's quit");
            if ([delegate respondsToSelector:@selector(parser:doneWithMetadata:)]) {
                [delegate parser:self doneWithMetadata:metaData];
            }
        }
        return;
    }
	
	/* recurse */
	if (!done) {
		[self parseAtoms];
	}
}

@end
