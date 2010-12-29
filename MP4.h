//
//  MP4.h
//  OHMTagLib
//
//  Created by Tobias Hieta on 2010-12-20.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OHMTagLibReader.h"
#import "mp4ff.h"

@interface MP4DataBuffer : NSObject {
	NSData *bufferData;
	uint64_t pos;
}

-(id)initWithData:(NSData*)data;
-(BOOL)readDataFromPos:(char*)buffer length:(uint32_t)length;

@property (nonatomic, assign) uint64_t pos;

@end

@interface MP4 : NSObject<OHMTagLibReader> {
	OHMTagLibMetadataRequest *request;
	NSString *name;
	uint32_t pos;	
}

@end
