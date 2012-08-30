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
#import "AppDelegate.h"

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


+ (BOOL) changeEncFSPasswd:(NSString *)path
                 oldPasswd:(NSString *)oldPasswd
                 newPasswd:(NSString *)newPasswd;


+ (void) archiveDirectoryList:(boost::shared_ptr<DirectoryMap>)directories
                       toFile:(NSString*)file;

+ (boost::shared_ptr<DirectoryMap>) unarchiveDirectoryListFromFile:(NSString*)file;


+ (BOOL)fileHandleIsReadable:(NSFileHandle*)fh;

+ (NSString*) appBundlePath;

+ (NSString*) locateDropboxFolder;

+ (BOOL) validateEmail: (NSString *) candidate;

+ (NSString*) getRealPathByResolvingSymlinks:(NSString*) path;


+ (NSString*) findCurrentlySelectedDirInFinder;
+ (NSString*) findCurrentlyOpenDirInFinder;
+ (BOOL) openMountedPathInTopFinderWindow:(NSString*)diskName;
+ (BOOL) openMountedPathInFinderSomehow:(NSString*)sourcepath
                            mountedPath:(NSString*)mountedpath;

@end