/*
 *  Version.h
 *  MacTrek
 *
 *  Created by Chris & Judith Lukassen on 19/11/2006.
 *  Copyright 2006 Luky Soft. See Licence.txt for licence details.
 *
 */

//#define VERSION						@"1.2.0"
#define VERSION                     [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]
#define APP_NAME					@"MacTrek"


#define APP_NAME_WITH_VERSION		[NSString stringWithFormat:@"%@ %@", APP_NAME, VERSION]; 

