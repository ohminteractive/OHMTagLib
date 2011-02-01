//
//  MP4.h
//  OHMTagLib
//
//  Created by Tobias Hieta on 2010-12-20.
//  Copyright 2010 OHM Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OHMTagLibReader.h"
#import "MP4Parser.h"
#import "MP4Atom.h"

@interface MP4 : NSObject<OHMTagLibReader,MP4ParserDelegate> {
    id<OHMTagLibReaderDelegate> delegate;
    OHMPositionalBuffer *buffer;
    MP4Parser *parser;
}

@end
