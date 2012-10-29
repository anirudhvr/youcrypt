//
//  YoucryptService.m
//  Youcrypt Mac alpha
//
//  Created by Anirudh Ramachandran on 6/19/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "YoucryptService.h"
#import "AppDelegate.h"

@implementation YoucryptService


- (void)doDecrypt:(NSPasteboard *)pboard
         userData:(NSString *)data
            error:(NSString **)error
{
    (void)data;
    NSArray *types;    
    types = [pboard types];
    
    if (![types containsObject:NSURLPboardType]) {
        *error = NSLocalizedString(@"Error: Pasteboard deosn't contain URL", @"Pasteboard didn't give url");
        return;
    }
    
    NSURL *url = [NSURL URLFromPasteboard:pboard];
    NSString *path = [url path];
    
    [theApp openEncryptedFolder:path];    
    return;    
}

- (void)doEncrypt:(NSPasteboard *)pboard
         userData:(NSString *)data
            error:(NSString **)error
{
    (void)data;
    NSArray *types;    
    types = [pboard types];
    
    if (![types containsObject:NSURLPboardType]) {
        *error = NSLocalizedString(@"Error: Pasteboard deosn't contain URL", @"Pasteboard didn't give url");
        return;
    }
    
    NSArray *classes = [NSArray arrayWithObject:[NSURL class]];
//    NSDictionary *options = [NSDictionary dictionaryWithObject:
//                             [NSNumber numberWithBool:YES] forKey:NSPasteboardURLReadingFileURLsOnlyKey];
    NSDictionary *options = [NSDictionary dictionary];

    NSArray *fileURLs = [pboard readObjectsForClasses:classes options:options];
    for (NSURL *u in fileURLs) {
        NSString *path = [u path];
        [theApp encryptFolder:path];
    }
//    NSURL *url = [NSURL URLFromPasteboard:pboard];
//    NSString *path = [url path];
//    [theApp encryptFolder:path];
    return;
}

- (void)doDecryptAndRestore:(NSPasteboard *)pboard
         userData:(NSString *)data
            error:(NSString **)error
{
    (void)data;
    NSArray *types;    
    types = [pboard types];
    
    if (![types containsObject:NSURLPboardType]) {
        *error = NSLocalizedString(@"Error: Pasteboard deosn't contain URL", @"Pasteboard didn't give url");
        return;
    }
    
    NSURL *url = [NSURL URLFromPasteboard:pboard];
    NSString *path = [url path];
    
    [theApp removeFSAtPath:path];
}


@end

