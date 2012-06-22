//
//  libFunction.h
//  EasyEnc
//
//  Created by Anirudh Ramachandran on 6/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface libFunctions : NSObject {
    
}

extern NSString* systemCall(NSString *binary, NSArray *arguments);
void mkdirRecursive(NSString *path);
void mkdirRecursive2(NSString *path);
void mkdir(NSString *path);
void mvRecursive(NSString *pathFrom, NSString *pathTo);

+ (NSString*) getPassphraseFromKeychain;
+ (BOOL)registerWithKeychain:(NSString*)passphrase;

@end