//
//  MP4Atom.h
//  OHMTagLib
//
//  Created by Tobias Hieta on 2010-12-29.
//  Copyright 2010 OHM Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MP4AtomTypes.h"

@interface MP4Atom : NSObject {
	UInt8 type;
	SInt32 size;
	NSData *data;
	NSMutableArray *subatoms;
}

+(MP4Atom*)getAtomFromData:(NSData *)data_ error:(NSError**)err_;
+(NSString*)getAtomNameFromType:(UInt32)type_;
+(SInt32)getAtomSize:(NSData *)data_;
+(UInt8)getAtomType:(NSData *)data_;

@property (nonatomic, assign) UInt8 type;
@property (nonatomic, readonly) NSString *typeName;
@property (nonatomic, assign) SInt32 size;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, readonly) NSArray *subatoms;

@end
