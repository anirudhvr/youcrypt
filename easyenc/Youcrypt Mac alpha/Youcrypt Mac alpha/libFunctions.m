//
//  libFunctions.m
//  EasyEnc
//
//  Created by Anirudh Ramachandran on 6/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "libFunctions.h"
#import "SSKeychain.h"

@implementation libFunctions


+ (NSString*) getPassphraseFromKeychain
{
    NSError *error = nil;
    NSString *passphraseFromKeychain = [SSKeychain passwordForService:@"Youcrypt" account:@"avr" error:&error];
    
    if (error) {
        NSLog(@"Did not get passphrase");
        return nil;
    } else {
        NSLog(@"Got passphrase");
        return passphraseFromKeychain;
    }
}


/* Register password with Mac keychain */
+ (BOOL)registerWithKeychain:(NSString*)passphrase
{
    NSString *yourPasswordString = passphrase;
    NSError *error = nil;
    
    if([SSKeychain setPassword:yourPasswordString forService:@"Youcrypt" account:@"avr" error:&error])
        NSLog(@"Successfully registered passphrase wiht keychain");
    if (error) {
        NSLog(@"Error registering with Keychain");
        NSLog(@"%@",[error localizedDescription]);
        return NO;
    }
    return YES;
}

@end

NSString* systemCall(NSString *binary, NSArray *arguments) {
    NSTask *task;   
    task = [[NSTask alloc] init];
    [task setLaunchPath: binary];
    
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    [task launch];
    
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    
    [task waitUntilExit]; 
    //[task release];
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; 
    
    NSLog (@"got\n%@", string); 
    
    return string;
}

void mkdirRecursive(NSString *path)
{
    NSString *command = [[@"mkdir -p \"" stringByAppendingString:path] stringByAppendingString:@"\""];
    
    NSLog(@"mkdir -p this [%@]", command);
    
    char *cmd = [command UTF8String];
    char *out, *err;
    int outlen,errlen;
    
    if(run_command(cmd, &out, &outlen, &err, &errlen)) {
            NSLog(@"folder create fail");
    } else {
        NSLog(@"folder created");
    }
    
}

void mkdirRecursive2(NSString *path)
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDir;
	NSString *directoryAbove = [path stringByDeletingLastPathComponent];
	NSLog(@"Checking %@",directoryAbove);
    	if(![directoryAbove isEqualToString:@""]) {
		if (![fileManager fileExistsAtPath:directoryAbove isDirectory:&isDir])
		{
			NSLog(@"Going to create %@",directoryAbove);
			mkdirRecursive2(directoryAbove);
		}
	} 
	else {
		NSLog(@"FATAL !!!");
	}
	
	[fileManager createDirectoryAtPath:path attributes:nil];
}

void mkdir(NSString *path)
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager createDirectoryAtPath:path attributes:nil];
}

/**
 
 mvRecursive
 
 Recursively move contents of one directory to another
 
 pathFrom - directory whose contents we're moving
 pathTo - directory to where we're moving the contents
 
 **/

void mvRecursive(NSString *pathFrom, NSString *pathTo) {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSArray *files = [manager contentsOfDirectoryAtPath:pathFrom error:nil];
	
	for (NSString *file in files) {
		NSString *fileFrom = [pathFrom stringByAppendingPathComponent:file];
		NSString *fileTo = [pathTo stringByAppendingPathComponent:file];
		
		NSError  *error  = nil;
		
		NSLog(@"about to copy %@",fileFrom);
		
		[manager copyItemAtPath:fileFrom toPath:fileTo error:&error];
		[manager removeItemAtPath:fileFrom error:&error];
		if (error) {
			NSLog(@"%@",[error localizedDescription]);
		}
	}
}	





