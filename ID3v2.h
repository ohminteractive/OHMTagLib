//
//  ID3v2.h
//  OHMTagLib
//
//  Created by Tobias Hieta on 2010-12-13.
//  Copyright 2010 OHM Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OHMTagLibReader.h"
#import "OHMTagLibMetadataRequest.h"

@interface ID3v2 : NSObject<OHMTagLibReader> {
    OHMPositionalBuffer *buffer;
    id<OHMTagLibReaderDelegate> delegate;
}

@end
