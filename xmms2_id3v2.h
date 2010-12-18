/*
 *  xmms2_id3v2.h
 *  OHMTagLib
 *
 *  Created by Tobias Hieta on 2010-12-13.
 *  Copyright 2010 OHM Interactive. All rights reserved.
 *
 */

//  Most code here is from the XMMS2 project, this is their header:
/*  XMMS2 - X Music Multiplexer System
 *  Copyright (C) 2003-2009 XMMS2 Team
 *
 *  PLUGINS ARE NOT CONSIDERED TO BE DERIVED WORK !!!
 */


#import <Foundation/Foundation.h>
#import "OHMTagLibMetadata.h"

typedef struct xmms_id3v2_header_St {
	unsigned char ver;
	unsigned char rev;
	unsigned long int flags;
	unsigned long int len;
} xmms_id3v2_header_t;

BOOL xmms_id3v2_is_header (unsigned char *buf, xmms_id3v2_header_t *header);
BOOL xmms_id3v2_parse (OHMTagLibMetadata *entry, unsigned char *buf, xmms_id3v2_header_t *head, NSError **error);
