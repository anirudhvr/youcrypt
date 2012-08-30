//
//  BoxFSA.m
//  RKMacOSX
//
//  Created by Hardik Ruparel on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BoxFSA.h"
#import "XMLReader.h"

@implementation BoxFSA

@synthesize apiKey;
@synthesize baseURL;
@synthesize state;
@synthesize ticket;
@synthesize authToken;


-(id) init
{
    self = [super init];
    apiKey = @"az9ug6vjgygca8qbf3x3txldhoro5jbr";
    baseURL = @"https://www.box.com/api";
    return self;
}

-(NSString*)makeRestCall:(NSString*)reqURL:(BOOL)isMutable
{
    NSURLRequest *theRequest;
    if(isMutable){
        NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:reqURL]];
        NSString *authHeader = [NSString stringWithFormat:@"BoxAuth api_key=%@&auth_token=%@",apiKey,authToken];
        [mutableRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
        theRequest = (NSURLRequest*)mutableRequest;
    }
    else {
        theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:reqURL]];
    }
    NSURLResponse *resp = nil;
    NSError *error = nil;
    NSData *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &error];
    NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]; 
    
    NSLog(@"rest response string:%@",responseString);
    return responseString;
}

-(void) auth
{
    NSLog(@"IN AUTH");
    NSString *reqURL = [NSString stringWithFormat:@"%@/1.0/rest?action=get_ticket&api_key=%@",baseURL,apiKey];
    NSString *response = [self makeRestCall:reqURL:NO];
    NSError *error = nil;
    NSDictionary *res = [XMLReader dictionaryForXMLString:response error:&error];
    ticket = [[[res objectForKey:@"response"] objectForKey:@"ticket"] objectForKey:@"text"];
    NSLog(@"TICKET: %@",ticket);
    NSString *authURL = [NSString stringWithFormat:@"%@/1.0/auth/%@",baseURL,ticket];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:authURL]];
 
}

- (void) getAuthToken
{
    NSLog(@"ticket : %@",ticket);

    NSString *authURL = [NSString stringWithFormat:@"%@/1.0/auth/%@",baseURL,ticket];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:authURL]];
    
   
}

-(NSString*)userGavePerms
{
    NSString *reqURL = [NSString stringWithFormat:@"%@/1.0/rest?action=get_auth_token&api_key=%@&ticket=%@",baseURL,apiKey,ticket];
    NSString *response = [self makeRestCall:reqURL:NO];
    NSError *error = nil;
    NSDictionary *res = [XMLReader dictionaryForXMLString:response error:&error];
    if([[[[res objectForKey:@"response"] objectForKey:@"status"] objectForKey:@"text"] isEqualToString:@"not_logged_in"]) {
        return @"";
    }
    authToken = [[[res objectForKey:@"response"] objectForKey:@"auth_token"] objectForKey:@"text"];
    NSLog(@"AUTHTOKEN: %@",authToken);
    return authToken;
}

-(IBAction)getFolderList:(id)sender
{
    (void)sender;
    NSString *reqURL = @"/2.0/folders/0.xml";
    
    [self makeRestCall:reqURL:NO];

}

-(void)getFolderCollabs:(NSString*)folderID
{
    NSString *reqURL = [NSString stringWithFormat:@"/1.0/rest?action=invite_collaborators&api_key=%@&auth_token=%@&target=folder&target_id=%@&user_ids[]=&emails[]=anirudhvr@gmail.com&item_role_name=editor&resend_invite=0&no_email=0&params[]=force_accept",apiKey,authToken,folderID];
    [self makeRestCall:reqURL:NO];
    
}

@end
