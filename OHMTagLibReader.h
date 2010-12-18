//
//  OHMTagLibReader.h
//  OHMTagLib
//
//  Created by Tobias Hieta on 2010-12-13.
//  Copyright 2010 OHM Interactive. All rights reserved.
//

#import "OHMTagLibMetadata.h"

@protocol OHMTagLibReader;

#import "OHMTagLibMetadataRequest.h"

@protocol OHMTagLibReader

/* pass at least 10 bytes for mp3 files */
+(BOOL)isMine:(NSData*)data;
-(OHMTagLibMetadata*)parse:(NSError**)error;

@property (retain, nonatomic) OHMTagLibMetadataRequest *request;
@property (readonly, nonatomic) NSString *name;

@end
