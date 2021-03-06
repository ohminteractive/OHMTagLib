//
//  OHMTagLibMetadata.m
//  OHMTagLib
//
//  Created by Tobias Hieta on 2010-12-13.
//  Copyright 2010 OHM Interactive. All rights reserved.
//

#import "OHMTagLibMetadata.h"


@implementation OHMTagLibMetadata

@synthesize artist, album, title, tracknr, year, partofset, isPodcast;

-(NSString*)description
{
    return [NSString stringWithFormat:@"artist = %@\nalbum = %@\ntitle = %@", 
            self.artist, self.album, self.title];
}

@end
