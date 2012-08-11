//
//  main.m
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "libFunctions.h"


int main(int argc, char *argv[])
{
    [libFunctions encryptFolderInPlace:@"/tmp/s/" passphrase:@"asdf" encryptFilenames:YES];
    return NSApplicationMain(argc, (const char **)argv);
}
