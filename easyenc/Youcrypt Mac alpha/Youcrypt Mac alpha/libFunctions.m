//
//  libFunctions.m
//  EasyEnc
//
//  Created by Anirudh Ramachandran on 6/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "libFunctions.h"
#import "logging.h"

@implementation libFunctions

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

@end