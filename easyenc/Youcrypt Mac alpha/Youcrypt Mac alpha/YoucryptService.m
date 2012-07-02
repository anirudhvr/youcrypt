//
//  YoucryptService.m
//  Youcrypt Mac alpha
//
//  Created by Anirudh Ramachandran on 6/19/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "YoucryptService.h"
#import "Encrypt.h"
#import "Decrypt.h"
#import "YoucryptConfigDirectory.h"

@implementation YoucryptService


- (void)setApp:(AppDelegate*)x;
{
    mainApp = x;
}


- (void)openDecryptWindow:(NSPasteboard *)pboard
              userData:(NSString *)data
                 error:(NSString **)error
{
    NSArray *types;
    
    types = [pboard types];
    
    if (![types containsObject:NSURLPboardType]) {
        *error = NSLocalizedString(@"Error: Pasteboard deosn't contain URL", @"Pasteboard didn't give url");
        return;
    }
    
    NSURL *url = [NSURL URLFromPasteboard:pboard];
    NSString *path = [url path];
    
    
    [mainApp showDecryptWindow:mainApp];
    
    
    Decrypt *dc = mainApp.decryptController;
    dc.sourceFolderPath = path;
    
    
    NSString *dest = [[mainApp.configDir.youCryptVolDir stringByAppendingPathComponent:path] stringByDeletingPathExtension];
    
    [dc setDestFolderPath:dest];
    
    NSLog(@"openDecryptWindow Path: [%@, %@]\n", path, dest); 

    
    return;
    
}


- (void)openEncryptWindow:(NSPasteboard *)pboard
              userData:(NSString *)data
                 error:(NSString **)error
{
//    NSString *pboardString;
    NSArray *types;
    
    types = [pboard types];
    
    if (![types containsObject:NSURLPboardType]) {
        *error = NSLocalizedString(@"Error: Pasteboard deosn't contain URL", @"Pasteboard didn't give url");
        return;
    }

    NSURL *url = [NSURL URLFromPasteboard:pboard];
    NSString *path = [url path];
    

    [mainApp showEncryptWindow:mainApp];
    
    
    Encrypt *ec = mainApp.encryptController;
    ec.sourceFolderPath = path;
    
    
    NSString *dest = [[mainApp.configDir.youCryptVolDir stringByAppendingPathComponent:path] stringByDeletingPathExtension];
    
    [ec setDestFolderPath:dest];
    
    NSLog(@"openEncryptWindow Path: [%@, %@]\n", path, dest); 
    
   
    return;
}


/* This is an example of a service which doesn't return a value...
 */
- (void)writeToTmpFile:(NSPasteboard *)pboard
                 userData:(NSString *)data
                    error:(NSString **)error
{
    NSString *pboardString;
    NSArray *types;
    
    types = [pboard types];
    
    if (![types containsObject:NSURLPboardType]) {
        *error = NSLocalizedString(@"Error: Pasteboard deosn't contain URL", @"Pasteboard didn't give url");
        return;
    }
    NSURL *url = [NSURL URLFromPasteboard:pboard];
    
    NSFileHandle *file;
    file = [NSFileHandle fileHandleForWritingAtPath: @"/tmp/foo.foo"];
    
    if (file == nil)
        NSLog(@"Failed to open file %@", pboardString);
    

    [file seekToEndOfFile];
    NSData *dataToWrite = [[url path] dataUsingEncoding:NSUTF8StringEncoding];
    [file writeData:dataToWrite];
    
    [file closeFile];
            
    return;
}

@end

