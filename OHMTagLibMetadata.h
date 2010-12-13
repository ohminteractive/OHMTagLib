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
}

@property (assign, nonatomic) NSString *artist;
@property (assign, nonatomic) NSString *album;
@property (assign, nonatomic) NSString *title;
@property (assign, nonatomic) NSString *year;
@property (assign, nonatomic) NSNumber *tracknr;
@property (assign, nonatomic) NSNumber *partofset;

@end
