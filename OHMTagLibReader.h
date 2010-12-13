//
//  OHMTagLibReader.h
//  OHMTagLib
//
//  Created by Tobias Hieta on 2010-12-13.
//  Copyright 2010 OHM Interactive. All rights reserved.
//

#import "OHMTagLibMetadata.h"

@protocol OHMTagLibReaderDelegate

-(NSData*)needMoreData:(NSInteger)bytes;

@end


@protocol OHMTagLibReader

/* pass at least 10 bytes for mp3 files */
-(BOOL)isMine:(NSData*)data;
-(OHMTagLibMetadata*)parse;
-(NSString*)name;

@property (assign, nonatomic) id<OHMTagLibReaderDelegate>delegate;
@property (assign, nonatomic) NSData *data;

@end
