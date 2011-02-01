//
//  MP4AtomTypes.h
//  OHMTagLib
//
//  Created by Tobias Hieta on 2011-01-20.
//  Copyright 2011 OHM Interactive. All rights reserved.
//

#define kOHMMP4CopyrightSymbol ((int8_t)0xA9)

typedef enum {
    kOHMMP4AtomFTYP,
    kOHMMP4AtomMOOV,
    kOHMMP4AtomUDAT,
    kOHMMP4AtomILST,
    kOHMMP4AtomMETA,
    kOHMMP4AtomARTIST,
    kOHMMP4AtomALBUM,
    kOHMMP4AtomTITLE,
    kOHMMP4AtomGENRE,
    kOHMMP4AtomPODCAST,
    kOHMMP4AtomDATE,
    kOHMMP4AtomDATA,
    kOHMMP4AtomCOMPILATION,
    kOHMMP4AtomUnknown = 255
} kOHMMP4AtomTypes;
