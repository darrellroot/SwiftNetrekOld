//
//  RSAWrapper.m
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 15/11/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "RSAWrapper.h"

@implementation RSAWrapper

// creates a response to the RSA data block, the comm handler needs to send it
- (NSMutableData *) encode:(NSMutableData *)data forHost:(LLHost*)host onPort:(int)port {
	
	int KEY_SIZE = 32;

	// get a pointer to the data
	unsigned char *pData = (unsigned char*)[data bytes];
	
	// put the adress in the first 4 bytes
	unsigned char *pAddress = (unsigned char*)[[host firstAddressData] bytes];
	LLLog(@"RSAWrapper.encode: addr %x%x%x%x", pAddress[0], pAddress[1],  pAddress[2],  pAddress[3]); 
		
		
	memcpy(pData, pAddress, 4);
	
	// then the port
	pData[4] = (char)((port >> 8) & 0xFF);
	pData[5] = (char)(port & 0xFF);
	
	// create a response buffer
	// consisting of global[KEY_SIZE] followed by public[KEY_SIZE] followed by resp[KEY_SIZE]
	NSMutableData *response = [[NSMutableData alloc] initWithLength:KEY_SIZE*3];
	//unsigned char *pResponse = (unsigned char*)[response mutableBytes];
	
	// decode the key
	// void rsa_black_box(unsigned char *out, unsigned char *in, unsigned char *public, unsigned char *global) 
	
	/* 
		The following code is a call to the netrek RSA black box. This code is not part of the MacTrek 
		repository since it contains the key for RSA (duh..)
		To compile your version of mactrek comment out the line below to disable the rsa response.
		Alternatively download the rsa engine from sourceforge.net/projects/netrek
		(i used 2.9.2 compiled against gmp 4.2) and generate a new key with corresponding files
		rsa_box.c, rsa_box_0.c, rsa_box_1.c, rsa_box_2.c, rsa_box_3.c, rsa_box_4.c
	    and get your key to the servers of course :-)
	 */
	
	LLLog(@"RSAWrapper.encode: decoding RSA request");	
	//rsa_black_box(pResponse+2*KEY_SIZE, pData, pResponse+KEY_SIZE, pResponse);
	LLLog(@"RSAWrapper.encode: complete");
	return response;	
}

@end
