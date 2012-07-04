//
//  libFunctions.m
//  EasyEnc
//
//  Created by Anirudh Ramachandran on 6/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "libFunctions.h"

#import "SSKeychain.h"
#import "logging.h"
#import "pipetest.h"

@implementation libFunctions


+ (NSString*)getPassphraseFromKeychain:(NSString*)service;
{
    NSError *error = nil;
    NSString *passphraseFromKeychain = [SSKeychain passwordForService:service account:NSUserName() error:&error];
    
    if (error) {
        NSLog(@"Did not get passphrase");
        return nil;
    } else {
        NSLog(@"Got passphrase");
        return passphraseFromKeychain;
    }
}


/* Register password with Mac keychain */
+ (BOOL)registerWithKeychain:(NSString*)passphrase:(NSString*)service;
{
    NSString *yourPasswordString = passphrase;
    NSError *error = nil;
    
    if([SSKeychain setPassword:yourPasswordString forService:service account:NSUserName() error:&error])
        NSLog(@"Successfully registered passphrase wiht keychain");
    if (error) {
        NSLog(@"Error registering with Keychain");
        NSLog(@"%@",[error localizedDescription]);
        return NO;
    }
    return YES;
}



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
    
    //DDLogVerbose (@"got\n%@", string); 
    
    return string;
}

void mkdirRecursive(NSString *path) {
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}


void mkdirRecursive3(NSString *path)
{
    NSString *command = [[@"mkdir -p \"" stringByAppendingString:path] stringByAppendingString:@"\""];
    
    NSLog(@"mkdir -p this [%@]", command);
    
    const char *cmd = [command UTF8String];
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
		
		[manager moveItemAtPath:fileFrom toPath:fileTo error:&error];
		//[manager removeItemAtPath:fileFrom error:&error];
		if (error) {
			NSLog(@"%@",[error localizedDescription]);
		}
	}
}	


int execWithSocket(NSString *path, NSArray *arguments) {
    int sockDescriptors[2];
    pid_t pid;
    
    if (socketpair(AF_LOCAL, SOCK_STREAM, 0, sockDescriptors) == -1)
    {
        perror("socketpair");
        return -1;
    }
    
    if ((pid = fork()) == -1)
    {
        perror("fork");
        return -1;
    }
    else if (pid == 0) { 
        // This is the child.  Use sockDescriptors[0] here.
        close(0);
        dup2(sockDescriptors[0], 0);
        dup2(sockDescriptors[0], 1);

        execl([path cStringUsingEncoding:NSUTF8StringEncoding],
              [path cStringUsingEncoding:NSUTF8StringEncoding],
//              [[NSString stringWithFormat:@"%d", sockDescriptors[0]] cStringUsingEncoding:NSUTF8StringEncoding],
              (char *)0);
        perror("execl");
        return -1;
    }
    else { 
        // This is the parent
        // Write all the arguments to the socket.        
        // Use sockDescriptors[1] here.
        
        int argc = [arguments count];
        int sock = sockDescriptors[1];
        int status;
        write (sock, &argc, sizeof(argc));
        for (int i=0; i<argc; i++) {
            const char *arg = [[arguments objectAtIndex:i] cStringUsingEncoding:NSUTF8StringEncoding];
            int len = strlen(arg);
            write (sock, &len, sizeof(len));
            write (sock, arg, len);
        }        
        waitpid(pid, &status, 0);
        return sock;   
    }
}








@end
