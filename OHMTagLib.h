//
//  OHMTagLib.h
//  OHMTagLib
//
//  Created by Tobias Hieta on 2010-12-13.
//  Copyright 2010 OHM Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OHMTagLibMetadata.h"
#import "OHMTagLibDelegate.h"
#import "OHMTagLibReader.h"

@interface OHMTagLib : NSObject<OHMTagLibReaderDelegate> {
	NSArray *_readers;
	id delegate;
}

-(BOOL)canHandleData:(NSData *)data;
-(OHMTagLibMetadata*)getMetadataFromData:(NSData *)data;

@property (assign, nonatomic) id<OHMTagLibDelegate> delegate;

@end
