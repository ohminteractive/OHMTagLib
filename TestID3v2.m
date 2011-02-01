//
//  TestID3v2.m
//  OHMTagLib
//
//  Created by Tobias Hieta on 2011-01-02.
//  Copyright 2011 Purple Scout. All rights reserved.
//

#import "TestID3v2.h"


@implementation TestID3v2

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

- (void) testAppDelegate {
    
    id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
    
}

#else                           // all code under test must be linked into the Unit Test bundle

- (void) testMath {
    
    STAssertTrue((1+1)==2, @"Compiler isn't feeling well today :-(" );
    
}


#endif


@end
