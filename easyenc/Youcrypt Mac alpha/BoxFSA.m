//
//  BoxFSA.m
//  RKMacOSX
//
//  Created by Hardik Ruparel on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BoxFSA.h"
#import "RestKit/XMLReader.h"
#import "RestKit/RestKit.h"

@implementation BoxFSA

@synthesize apiKey;
@synthesize baseURL;
@synthesize state;
@synthesize ticket;
@synthesize authToken;

@synthesize client = _client;

-(id) init
{
    self = [super init];
    apiKey = @"az9ug6vjgygca8qbf3x3txldhoro5jbr";
    baseURL = @"https://www.box.com/api";
    return self;
}


-(void) auth
{
    NSLog(@"IN AUTH");
    self.client = [RKClient clientWithBaseURL:[RKURL URLWithBaseURLString:baseURL]];
    NSString *reqURL = [NSString stringWithFormat:@"/1.0/rest?action=get_ticket&api_key=%@",apiKey];
    [self.client get:reqURL delegate:self];
    
}

- (void) getAuthToken
{
    NSLog(@"ticket : %@",ticket);

    NSString *authURL = [NSString stringWithFormat:@"%@/1.0/auth/%@",baseURL,ticket];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:authURL]];
    
   
}

-(void)userGavePerms
{
    NSString *reqURL = [NSString stringWithFormat:@"/1.0/rest?action=get_auth_token&api_key=%@&ticket=%@",apiKey,ticket];

    [self.client get:reqURL delegate:self];

}

-(IBAction)getFolderList:(id)sender
{
    NSString *reqURL = @"/2.0/folders/0.xml";
    NSString *auth = [NSString stringWithFormat:@"BoxAuth api_key=%@&auth_token=%@",apiKey,authToken];
    [self.client setValue:auth forHTTPHeaderField:@"Authorization"];
    [self.client get:reqURL delegate:self];

}

-(void)getFolderCollabs:(NSString*)folderID
{
    NSString *reqURL = [NSString stringWithFormat:@"/1.0/rest?action=invite_collaborators&api_key=%@&auth_token=%@&target=folder&target_id=%@&user_ids[]=&emails[]=anirudhvr@gmail.com&item_role_name=editor&resend_invite=0&no_email=0&params[]=force_accept",apiKey,authToken,folderID];
    [self.client get:reqURL delegate:self];
    
}
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse *)response {
    state = @"gotResponse";
    NSLog(@"Loaded XML: %@", [response bodyAsString]);
    NSError *error;
    
    NSDictionary *res = [XMLReader dictionaryForXMLString:[response bodyAsString] error:&error];
    
    if(error){
       // NSLog(@"%@",[error localizedDescription]);
    }
    else NSLog(@"NO ERROR");
    
    NSString *responseType = [[res objectForKey:@"response"] objectForKey:@"status"];
    //NSLog([[res objectForKey:@"response"] objectForKey:@"ticket"]);
    if ([responseType isEqualToString:@"get_ticket_ok"]) {
        state = @"gotTicket";
        ticket = [[res objectForKey:@"response"] objectForKey:@"ticket"];
        NSLog(@"TICKET: %@",ticket);
        [self getAuthToken];
    }
    else if([responseType isEqualToString:@"get_auth_token_ok"]) {
        state = @"gotAuthToken";
        authToken = [[res objectForKey:@"response"] objectForKey:@"auth_token"];
        NSLog(@"AUTHTOKEN: %@",authToken);
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:authToken forKey:@"ycbox"];
        [defaults synchronize];
     //   [self getFolderCollabs:@"300572558"];
    } 
    else if([responseType isEqualToString:@"s_get_collaborations"]){
        NSDictionary *collaborationsDict = [[res objectForKey:@"response"] objectForKey:@"collaborations"];
        for( NSString *key in [collaborationsDict allKeys] )
        {
            NSLog(@"%@ : %@",key,[collaborationsDict objectForKey:key]);
        }
    }
}

@end
