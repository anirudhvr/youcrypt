//
//  BoxFSA.h
//  RKMacOSX
//
//  Created by Hardik Ruparel on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WebView; 

@interface BoxFSA : NSWindowController
{
    NSString *state;
    NSString *apiKey;
    NSString *ticket;
    NSString *baseURL;
    NSString *authToken;
    IBOutlet NSButton *button;
}

@property (atomic) NSString *apiKey;
@property (atomic) NSString *baseURL;
@property (atomic) NSString *state;
@property (atomic) NSString *ticket;
@property (atomic) NSString *authToken;

-(void) auth;
-(void) getAuthToken;
-(NSString*) userGavePerms;
//-(NSString*)makeRestCall:(NSString*)reqURL:(BOOL)mutable;

@end

