//
//  MP4.m
//  OHMTagLib
//
//  Created by Tobias Hieta on 2010-12-20.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import "MP4.h"
#import "mp4ff.h"
#import "OHMTagLibErrorCodes.h"

@implementation MP4DataBuffer

@synthesize pos;

-(id)initWithData:(NSData *)data
{
	if (self = [super init]) {
		bufferData = data;
		[bufferData retain];
		pos = 0;
	}
	
	return self;
}

-(BOOL)readDataFromPos:(char *)buffer length:(uint32_t)length
{
	if (!([bufferData length] >= (pos + length))) {
		NSLog(@"Our buffer is to small (%d), we would need a buffer that is at least %d big...", [bufferData length], pos + length);
		return NO;
	}
	[bufferData getBytes:buffer range:NSMakeRange(pos, length)];
	pos += length;
	return YES;
}

-(BOOL)setPosition:(uint64_t)newPosition
{
	if ([bufferData length] >= (newPosition)) {
		pos = newPosition;
		return YES;
	}
	return NO;
}

-(void)dealloc
{
	[bufferData release];
	[super dealloc];
}

@end


@implementation MP4

@synthesize name;
@synthesize request;

static uint32_t cb_read_directly (void *user_data, void *buffer, uint32_t length)
{
	MP4DataBuffer *dataBuffer = user_data;
//	NSLog(@"read: %d", length);
	if ([dataBuffer readDataFromPos:buffer length:length]) {
		return length;
	}
	NSLog(@"Failed to read .. ");
	return 0;
}

static uint32_t cb_seek_directly (void *user_data, uint64_t position)
{
//	NSLog(@"seek %lld", position);
	MP4DataBuffer *dataBuffer = user_data;
	if ([dataBuffer setPosition:position]) {
		return position;
	}
	NSLog(@"Failed to set position");
	return -1;
}

-(id)init
{
	if (self = [super init]) {
		name = @"mp4";
		pos = 0;
	}
	return self;
}

-(OHMTagLibMetadata*)parse:(NSError **)error
{
	mp4ff_callback_t cb;
	cb.read = cb_read_directly;
	cb.seek = cb_seek_directly;
	
	MP4DataBuffer *dbuff = [[MP4DataBuffer alloc] initWithData:request.data];
	cb.user_data = dbuff;
	
	mp4ff_t *mp4ff = mp4ff_open_read_metaonly (&cb);
	
	if (!mp4ff) {
		if (error) {
			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"File doesn't contain a MP4 header!", NSLocalizedDescriptionKey, nil];
			*error = [NSError errorWithDomain:kOHMTagLibErrorDomain code:kOHMTagLibErrorMetadataParser userInfo:dict];
		}
		return nil;
	}
	
	OHMTagLibMetadata *metaData = [[[OHMTagLibMetadata alloc] init] autorelease];
	char *tmp;
	if (mp4ff_meta_get_artist (mp4ff, &tmp)) {
		metaData.artist = [NSString stringWithCString:tmp encoding:NSUTF8StringEncoding];
		free (tmp);
	}
	
	if (mp4ff_meta_get_album (mp4ff, &tmp)) {
		metaData.album = [NSString stringWithCString:tmp encoding:NSUTF8StringEncoding];
		free (tmp);
	}

	if (mp4ff_meta_get_title (mp4ff, &tmp)) {
		metaData.title = [NSString stringWithCString:tmp encoding:NSUTF8StringEncoding];
		free (tmp);
	}

	if (mp4ff_meta_get_date (mp4ff, &tmp)) {
		metaData.year = [NSString stringWithCString:tmp encoding:NSUTF8StringEncoding];
		free (tmp);
	}

	if (mp4ff_meta_get_track (mp4ff, &tmp)) {
		int tracknr;
		char *end;
		
		tracknr = strtol (tmp, &end, 10);
		if (end && *end == '\0') {
			metaData.tracknr = [NSNumber numberWithInt:tracknr];
		}
		free (tmp);
	}
	
	NSLog(@"Needed %d bytes for this...", dbuff.pos);
	
	return metaData;
}

+(BOOL)isMine:(NSData *)data
{
	mp4ff_callback_t cb;
	cb.read = cb_read_directly;
	cb.seek = cb_seek_directly;
	
	MP4DataBuffer *dbuff = [[MP4DataBuffer alloc] initWithData:data];
	cb.user_data = dbuff;

	
	mp4ff_t *mp4ff = mp4ff_open_read_metaonly (&cb);
	if (!mp4ff) {
		NSLog(@"Failed to open mp4ff");
		return NO;
	}
	
	NSLog(@"This is a MP4 file!");
	
	return YES;
}

@end
