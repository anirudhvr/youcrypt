//
//  FeedbackSheetController.m
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 7/6/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "FeedbackSheetController.h"
#import "libFunctions.h"
#import "PreferenceController.h"

@interface FeedbackSheetController ()

@end

@implementation FeedbackSheetController

@synthesize message;
@synthesize anonymize;

- (id)init
{
    if (!(self = [super initWithWindowNibName:@"Feedback"])) {
        return nil; // Bail!
    }
    return self;
}

- (void)windowDidLoad                                               
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(IBAction)send:(id)sender
{
    NSLog(@"%ld",[anonymize state]);
    
    NSString *curlEmail;
    if([anonymize state]) {
        curlEmail = [NSString stringWithFormat:@"from=\"anonymous@youcrypt.com\""];
    }
    else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *userRealName = [defaults objectForKey:YC_USERREALNAME];
        NSString *userEmail = [defaults objectForKey:YC_USEREMAIL];
        curlEmail = [NSString stringWithFormat:@"from=\"%@ <%@>\"",userRealName,userEmail];
    }
    
    NSString *curlText   = [NSString stringWithFormat:@"text=\%@\"", [message stringValue]];

    /*[libFunctions execCommand:@"/usr/bin/curl" 
                    arguments:[NSArray arrayWithObjects: 
                               @"-s", @"-k", 
                               @"--user", @"api:key-67fgovcfrggd6y4l02ucpz-av4b22i26",
                               @"https://api.mailgun.net/v2/cloudclear.mailgun.org/messages",
                               @"-F", curlEmail,
                               @"-F", @"to='hardik988@gmail.com'",
                               @"-F", @"subject='Your Temporary Passphrase'",
                               @"-F", curlText,
                               nil]
                          env:nil];
    */
    
    NSArray *args = [NSArray arrayWithObjects: 
                     @"-s", @"-k", 
                     @"--user", @"api:key-67fgovcfrggd6y4l02ucpz-av4b22i26",
                     @"https://api.mailgun.net/v2/cloudclear.mailgun.org/messages",
                     @"-F", curlEmail,
                     @"-F", @"to=\"hardik988@gmail.com\"",
                     @"-F", @"subject='Your Temporary Passphrase'",
                     @"-F", curlText,
                     nil];
   // NSString *feedbackCall = [NSString stringWithFormat:@"/usr/bin/curl -s -k --user api:key-67fgovcfrggd6y4l02ucpz-av4b22i26 https://api.mailgun.net/v2/cloudclear.mailgun.org/messages -F %@ -F to='hardik988@gmail.com' -F subject='test' -F %@",curlEmail,curlText];
    
    NSFileHandle *fh = [NSFileHandle alloc];
    NSString *reply;
    NSTask *feedbackTask = [NSTask alloc];
    if ([libFunctions execWithSocket:@"/usr/bin/curl" arguments:args env:nil io:fh proc:feedbackTask]) {
        [feedbackTask waitUntilExit];
        NSData *bytes = [fh availableData];
        reply = [[NSString alloc] initWithData:bytes encoding:NSUTF8StringEncoding];
        
        [fh closeFile];
    } else {
        NSLog(@"FAILED");
    }
    
    NSLog(@"REPLY : %@",reply);
    
    
    [self endSheetWithReturnCode:kSheetReturnedSave];
}

- (void)sheetWillDisplay {
    [super sheetWillDisplay];
    NSLog(@"First run sheet will display");
    
    
}

-(IBAction)cancel:(id)sender
{
    [self endSheetWithReturnCode:kSheetReturnedCancel];
}

@end
