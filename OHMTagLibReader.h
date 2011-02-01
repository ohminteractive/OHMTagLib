//
//  OHMTagLibReader.h
//  OHMTagLib
//
//  Created by Tobias Hieta on 2010-12-13.
//  Copyright 2010 OHM Interactive. All rights reserved.
//

#import "OHMTagLibMetadata.h"
#import "OHMPositionalBuffer.h"

@protocol OHMTagLibReader;

@class OHMTagLibMetadataRequest;

@protocol OHMTagLibReaderDelegate <NSObject>

-(void)reader:(id<OHMTagLibReader>)reader readerError:(NSError*)error;
-(void)reader:(id<OHMTagLibReader>)reader gotMetadata:(OHMTagLibMetadata*)metaData;

@end

@protocol OHMTagLibReader <OHMPositionalBufferConsumerDelegate>

+(NSString*)name;

/* pass at least 10 bytes for mp3 files */
+(BOOL)isMine:(NSData*)data;

/* before calling anything here we need to set the buffer delegate
   otherwise it will error out */
-(void)readMetadata;

@property (nonatomic, retain) OHMPositionalBuffer *buffer;
@property (nonatomic, retain) id<OHMTagLibReaderDelegate> delegate;

@end
