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
#import <stdio.h>
#import <stddef.h>
#import <stdlib.h>
#import <sys/socket.h>
#import <sys/types.h>
#import <sys/un.h>
#import <string.h>



@interface libFunctions : NSObject {
    
}

+ (void) mkdirRecursive: (NSString *)path;
+ (void) mvRecursive:(NSString *)srcPath toPath:(NSString *)dstPath;
+ (BOOL) execWithSocket:(NSString *)path arguments:(NSArray *)arguments
                    env:(NSDictionary *)env
                     io:(NSFileHandle *)io 
                   proc:(NSTask *)proc;
+ (int) execCommand:(NSString *)path arguments:(NSArray *)arguments
                env:(NSDictionary *)env;


+ (NSString*)getPassphraseFromKeychain:(NSString*)service;
+ (BOOL)registerWithKeychain:(NSString*)passphrase:(NSString*)service;

+ (BOOL) createEncFS:(NSString *)encFolder
     decryptedFolder:(NSString *)decFolder
            numUsers:(int)numUsers
    combinedPassword:(NSString *)pwd;

+ (BOOL) mountEncFS:(NSString *)encFolder
    decryptedFolder:(NSString *)decFolder
           password:(NSString *)password
         volumeName:(NSString*) volname;

+ (BOOL) changeEncFSPasswd:(NSString *)path
                 oldPasswd:(NSString *)oldPasswd
                 newPasswd:(NSString *)newPasswd;



+ (void) archiveDirectoryList:directories 
                       toFile:file;
+ (void) unarchiveDirectoryList:directories
                       fromFile:file;


+ (BOOL)fileHandleIsReadable:(NSFileHandle*)fh;




@end