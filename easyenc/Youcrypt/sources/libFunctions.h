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

+ (BOOL) mkdirRecursive: (NSString *)path;
+ (BOOL) mvRecursive:(NSString *)srcPath toPath:(NSString *)dstPath;
+ (BOOL) execWithSocket:(NSString *)path arguments:(NSArray *)arguments
                    env:(NSDictionary *)env
                     io:(NSFileHandle *)io 
                   proc:(NSTask *)proc;
+ (int) execCommand:(NSString *)path arguments:(NSArray *)arguments
                env:(NSDictionary *)env;



+ (BOOL) createEncFS:(NSString *)encFolder
     decryptedFolder:(NSString *)decFolder
            numUsers:(int)numUsers
    combinedPassword:(NSString *)pwd
    encryptFilenames:(BOOL)encryptfilenames;

+ (BOOL) mountEncFS:(NSString *)encFolder 
    decryptedFolder:(NSString *)decFolder 
           password:(NSString*)password 
        fuseOptions:(NSDictionary*)fuseOpts
           idleTime:(int)idletime;

+ (BOOL) mountEncFS:(NSString *)encFolder
    decryptedFolder:(NSString *)decFolder
           password:(NSString *)password
         volumeName:(NSString*) volname;

+ (BOOL) changeEncFSPasswd:(NSString *)path
                 oldPasswd:(NSString *)oldPasswd
                 newPasswd:(NSString *)newPasswd;



+ (void) archiveDirectoryList:(id)directories 
                       toFile:(NSString*)file;
+ (id) unarchiveDirectoryListFromFile:(NSString*)file;


+ (BOOL)fileHandleIsReadable:(NSFileHandle*)fh;

+ (NSString*) appBundlePath;

+ (NSString*) locateDropboxFolder;

+ (BOOL) validateEmail: (NSString *) candidate;



@end