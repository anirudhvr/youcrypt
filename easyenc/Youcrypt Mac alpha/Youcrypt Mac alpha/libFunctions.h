//
//  libFunction.h
//  EasyEnc
//
//  Created by Anirudh Ramachandran on 6/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <string.h>
#import <stdlib.h>
#import <unistd.h>
#import <sys/socket.h>
#import <sys/un.h>
#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/un.h>
#include <string.h>



@interface libFunctions : NSObject {
    
}

extern NSString* systemCall(NSString *binary, NSArray *arguments);
void mkdirRecursive(NSString *path);
void mkdirRecursive2(NSString *path);
void mkdir(NSString *path);
void mvRecursive(NSString *pathFrom, NSString *pathTo);
int execWithSocket(NSString *path, NSArray *arguments);

+ (NSString*)getPassphraseFromKeychain:(NSString*)service;
+ (BOOL)registerWithKeychain:(NSString*)passphrase:(NSString*)service;

@end