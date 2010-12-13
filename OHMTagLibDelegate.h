//
//  OHMTagLibDelegate.h
//  OHMTagLib
//
//  Created by Tobias Hieta on 2010-12-13.
//  Copyright 2010 OHM Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol OHMTagLibDelegate

-(NSData*)needMoreData:(NSInteger)lenght;

@end
