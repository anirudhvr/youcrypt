//
//  StartOnLogin.h
//  StartOnLogin
//
//  Created by Anirudh Ramachandran on 6/28/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StartOnLogin : NSObject


- (NSURL *)appURL;  
- (BOOL)startAtLogin;
- (void)setStartAtLogin:(BOOL)enabled;
+ (BOOL) willStartAtLogin:(NSURL *)itemURL;
+ (void) setStartAtLogin:(NSURL *)itemURL enabled:(BOOL)enabled;


@end
