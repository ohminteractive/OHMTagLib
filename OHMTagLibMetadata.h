//
//  OHMTagLibMetadata.h
//  OHMTagLib
//
//  Created by Tobias Hieta on 2010-12-13.
//  Copyright 2010 OHM Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OHMTagLibMetadata : NSObject {
	NSString *artist, *album, *title, *year;
	NSNumber *tracknr;
	NSNumber *partofset;
    BOOL isPodcast;
}

@property (retain, nonatomic) NSString *artist;
@property (retain, nonatomic) NSString *album;
@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSString *year;
@property (retain, nonatomic) NSNumber *tracknr;
@property (retain, nonatomic) NSNumber *partofset;
@property (assign, nonatomic) BOOL isPodcast;

@end
