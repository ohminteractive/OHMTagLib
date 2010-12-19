/*
 *  xmms2_id3v2.c
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
#import "xmms2_id3v2.h"
#import "OHMTagLibErrorCodes.h"

#pragma mark XMMS2 functions

#define ID3v2_HEADER_FLAGS_UNSYNC 0x80
#define ID3v2_HEADER_FLAGS_EXTENDED 0x40
#define ID3v2_HEADER_FLAGS_EXPERIMENTAL 0x20
#define ID3v2_HEADER_FLAGS_FOOTER 0x10

#define ID3v2_HEADER_SUPPORTED_FLAGS (ID3v2_HEADER_FLAGS_UNSYNC | ID3v2_HEADER_FLAGS_FOOTER)

#define MUSICBRAINZ_VA_ID "89ad4ac3-39f7-470e-963a-56509c546377"
#define quad2long(a,b,c,d) ((a << 24) | (b << 16) | (c << 8) | (d))


BOOL
xmms_id3v2_is_header (unsigned char *buf, xmms_id3v2_header_t *header)
{
	typedef struct {
		/* All members are defined in terms of chars so padding does not
		 * occur. Is there a cleaner way to keep the compiler from
		 * padding? */
		
		unsigned char     id[3];
		unsigned char     ver;
		unsigned char     rev;
		unsigned char     flags;
		unsigned char     size[4];
	} id3head_t;
	
	id3head_t *id3head;
	
	id3head = (id3head_t *) buf;
	
	if (strncmp ((char *)id3head->id, "ID3", 3)) return FALSE;
	
	if (id3head->ver > 4 || id3head->ver < 2) {
		NSLog (@"Unsupported id3v2 version (%d)", id3head->ver);
		return FALSE;
	}
	
	if ((id3head->size[0] | id3head->size[1] | id3head->size[2] |
	     id3head->size[3]) & 0x80) {
		NSLog (@"id3v2 tag having lenbyte with msb set "
			   "(%02x %02x %02x %02x)!  Probably broken "
			   "tag/tag-writer. Skipping tag.",
			   id3head->size[0], id3head->size[1],
			   id3head->size[2], id3head->size[3]);
		return FALSE;
	}
	
	header->ver = id3head->ver;
	header->rev = id3head->rev;
	header->flags = id3head->flags;
	
	header->len = id3head->size[0] << 21 | id3head->size[1] << 14 |
	id3head->size[2] << 7 | id3head->size[3];
	
	if (id3head->flags & ID3v2_HEADER_FLAGS_FOOTER) {
		/* footer is copy of header */
		header->len += sizeof (id3head_t);
	}
	
	NSLog (@"Found id3v2 header (version=%d, rev=%d, len=%d, flags=%x)",
		   header->ver, header->rev, header->len, header->flags);
	
	return TRUE;
}

static NSStringEncoding
binary_to_enc (unsigned char val)
{
	NSStringEncoding retval;
	
	if (val == 0x00) {
		retval = NSISOLatin1StringEncoding;
	} else if (val == 0x01) {
		retval = NSUTF16StringEncoding;
	} else if (val == 0x02) {
		retval = NSUTF16BigEndianStringEncoding;
	} else if (val == 0x03) {
		retval = NSUTF8StringEncoding;
	} else {
		NSLog (@"UNKNOWN id3v2.4 encoding (%02x)!", val);
		retval = NSASCIIStringEncoding;
	}
	return retval;
}

static void
handle_int_field (OHMTagLibMetadata *entry, xmms_id3v2_header_t *head,
                  NSString *key, char *buf, size_t len)
{
	
	NSStringEncoding enc;
	
	enc = binary_to_enc (buf[0]);
	NSData *tmpData = [NSData dataWithBytes:&buf[1] length:len - 1];
	NSString *tmpStr = [[NSString alloc] initWithData:tmpData encoding:enc];
	
	if (tmpStr) {
		[entry setValue:[NSNumber numberWithInt:[tmpStr intValue]] forKey:key];
	}
	
	[tmpStr release];
	
}

struct id3tags_t {
	unsigned long int type;
	NSString* key;
	void (*fun)(OHMTagLibMetadata *, xmms_id3v2_header_t *, NSString *, char *, size_t); /* Instead of add_to_entry */
};

static struct id3tags_t tags[] = {
	{ quad2long ('T','Y','E',0), @"year", NULL },
	{ quad2long ('T','Y','E','R'), @"year", NULL },
	{ quad2long ('T','A','L',0), @"album", NULL },
	{ quad2long ('T','A','L','B'), @"album", NULL },
	{ quad2long ('T','T','2',0), @"title", NULL },
	{ quad2long ('T','I','T','2'), @"title", NULL },
	{ quad2long ('T','R','K',0),  @"tracknr", handle_int_field },
	{ quad2long ('T','R','C','K'),  @"tracknr", handle_int_field },
	{ quad2long ('T','P','1',0),  @"artist", NULL },
	{ quad2long ('T','P','E','1'), @"artist", NULL },
/*	{ quad2long ('T','C','O','N'), NULL, handle_id3v2_tcon },*/
	{ quad2long ('T','P','O','S'), @"partofset", handle_int_field },
/*	{ quad2long ('A','P','I','C'), NULL, handle_id3v2_apic },*/
/*	{ quad2long ('C','O','M','M'), NULL, handle_id3v2_comm },*/
	{ 0, NULL, NULL }
};

static void
add_to_entry (OHMTagLibMetadata *entry,
              xmms_id3v2_header_t *head,
              NSString *key,
              char *val,
              int len)
{
	NSString *nval;
	NSStringEncoding enc;
	
	if (len < 1)
		return;
	
	enc = binary_to_enc (val[0]);
	NSData *tmpData = [NSData dataWithBytes:&val[1] length:len-1];
	nval = [[NSString alloc] initWithData:tmpData encoding:enc];
	
	[entry setValue:nval forKey:key];
	
	[nval release];
	
}

static void
handle_id3v2_text (OHMTagLibMetadata *entry, xmms_id3v2_header_t *head,
                   unsigned long int type, char *buf, unsigned int flags, int len)
{
	int i = 0;
	
	if (len < 1) {
		NSLog (@"Skipping short id3v2 text-frame");
		return;
	}
	
	while (tags[i].type != 0) {
		if (tags[i].type == type) {
			if (tags[i].fun) {
				tags[i].fun (entry, head, tags[i].key, buf, len);
			} else {
				add_to_entry (entry, head, tags[i].key, buf, len);
			}
			return;
			break;
		}
		i++;
	}
	//NSLog (@"Unhandled tag %c%c%c%c", (type >> 24) & 0xff, (type >> 16) & 0xff, (type >> 8) & 0xff, (type) & 0xff);
}


BOOL
xmms_id3v2_parse (OHMTagLibMetadata *entry, unsigned char *buf, xmms_id3v2_header_t *head, NSError **error)
{
	int len=head->len;
	BOOL broken_version4_frame_size_hack = FALSE;
	
	if ((head->flags & ~ID3v2_HEADER_SUPPORTED_FLAGS) != 0) {
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"ID3v2 contain unsupported flags, skipping tags!",
							  NSLocalizedDescriptionKey, nil];
		*error = [NSError errorWithDomain:kOHMTagLibErrorDomain code:kOHMTagLibErrorMetadataParser userInfo:dict];
		return FALSE;
	}
	
	if (head->flags & ID3v2_HEADER_FLAGS_UNSYNC) {
		int i, j;
		NSLog (@"Removing false syncronisations from id3v2 tag");
		for (i = 0, j = 0; i < len; i++, j++) {
			buf[i] = buf[j];
			if (i < len-1 && buf[i] == 0xff && buf[i+1] == 0x00) {
				NSLog (@" - false sync @%d", i);
				/* skip next byte */
				i++;
			}
		}
		len = j;
		NSLog (@"Removed %d false syncs", i-j);
	}
	
	while (len>0) {
		size_t size;
		unsigned int flags;
		unsigned long int type;
		
		if (head->ver == 3 || head->ver == 4) {
			if ( len < 10) {
				NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Broken frame in ID3v2tag", NSLocalizedDescriptionKey, nil];
				*error = [NSError errorWithDomain:kOHMTagLibErrorDomain code:kOHMTagLibErrorMetadataParser userInfo:dict];
				return FALSE;
			}
			
			type = (buf[0]<<24) | (buf[1]<<16) | (buf[2]<<8) | (buf[3]);
			if (head->ver == 3) {
				size = (buf[4]<<24) | (buf[5]<<16) | (buf[6]<<8) | (buf[7]);
			} else {
				unsigned char *tmp;
				unsigned int next_size;
				
				if (!broken_version4_frame_size_hack) {
					size = (buf[4]<<21) | (buf[5]<<14) | (buf[6]<<7) | (buf[7]);
					/* The specs say the above, but many taggers (inluding iTunes)
					 * don't follow the spec and writes the int without synchsafe.
					 * Since we want to be according to the spec we try correct
					 * behaviour first, if that doesn't work out we try the former
					 * behaviour. Yay for specficiations.
					 *
					 * Identification of "erronous" frames aren't that pretty. We
					 * just check if the next frame seems to have a vaild size.
					 * This should probably be done better in the future.
					 * FIXME
					 */
					if (size + 18 <= len) {
						tmp = buf+10+size;
						next_size = (tmp[4]<<21) | (tmp[5]<<14) | (tmp[6]<<7) | (tmp[7]);
						
						if (next_size+10 > (len-size)) {
							NSLog (@"Uho, seems like someone isn't using synchsafe integers here...");
							broken_version4_frame_size_hack = TRUE;
						}
					}
				}
				
				if (broken_version4_frame_size_hack) {
					size = (buf[4]<<24) | (buf[5]<<16) | (buf[6]<<8) | (buf[7]);
				}
			}
			
			if (size+10 > len) {
				NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Broken frame in ID3v2tag", NSLocalizedDescriptionKey, nil];
				*error = [NSError errorWithDomain:kOHMTagLibErrorDomain code:kOHMTagLibErrorMetadataParser userInfo:dict];
				return FALSE;
			}
			
			flags = buf[8] | buf[9];
			
			if (buf[0] == 'T' || buf[0] == 'U' || buf[0] == 'A' || buf[0] == 'C') {
				handle_id3v2_text (entry, head, type, (char *)(buf + 10), flags, size);
			}
			
			if (buf[0] == 0) { /* padding */
				return TRUE;
			}
			
			buf += size+10;
			len -= size+10;
		} else if (head->ver == 2) {
			if (len < 6) {
				NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Broken frame in ID3v2tag", NSLocalizedDescriptionKey, nil];
				*error = [NSError errorWithDomain:kOHMTagLibErrorDomain code:kOHMTagLibErrorMetadataParser userInfo:dict];
				return FALSE;
			}
			
			type = (buf[0]<<24) | (buf[1]<<16) | (buf[2]<<8);
			size = (buf[3]<<16) | (buf[4]<<8) | buf[5];
			
			if (size+6 > len) {
				NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Broken frame in ID3v2tag", NSLocalizedDescriptionKey, nil];
				*error = [NSError errorWithDomain:kOHMTagLibErrorDomain code:kOHMTagLibErrorMetadataParser userInfo:dict];
				return FALSE;
			}
			
			if (buf[0] == 'T' || buf[0] == 'U' || buf[0] == 'C') {
				handle_id3v2_text (entry, head, type, (char *)(buf + 6), 0, size);
			}
			
			if (buf[0] == 0) { /* padding */
				return TRUE;
			}
			
			buf += size+6;
			len -= size+6;
		}
		
	}
	
	return TRUE;
}
