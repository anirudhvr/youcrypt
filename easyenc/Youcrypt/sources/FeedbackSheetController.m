//
//  FeedbackSheetController.m
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 7/6/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "FeedbackSheetController.h"
#import "logging.h"
#import "CompressingLogFileManager.h"
#import "libFunctions.h"
#import "PreferenceController.h"
#import "ConfigDirectory.h"
#import "AppDelegate.h"
#import "DDFileLogger.h"

@interface FeedbackSheetController ()

@end

@implementation FeedbackSheetController

@synthesize message;
@synthesize anonymize;
@synthesize logfiles;
@synthesize progressMessage;

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

- (void) awakeFromNib
{
    [message setStringValue:@""];
    [progressMessage setStringValue:@""];
}

-(IBAction)send:(id)sender
{

    [progressMessage setStringValue:@"Sending Feedback...."];
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
    
    
    NSMutableArray *args = [NSMutableArray arrayWithObjects: 
                     @"-s", @"-k", 
                     @"--user", @"api:key-67fgovcfrggd6y4l02ucpz-av4b22i26",
                     @"https://api.mailgun.net/v2/cloudclear.mailgun.org/messages",
                     @"-F", curlEmail,
                     @"-F", @"to=\"feedback@youcrypt.com\"",
                     @"-F", @"subject='Youcrypt Feedback'",
                     @"-F", curlText, 
            nil];
    
    if([logfiles state]) {
        // Include most recent log file.

        NSString *mostRecentLogFile = [[logFileManager sortedLogFilePaths] objectAtIndex:0];
        NSString *logFile = [NSString stringWithFormat:@"attachment=@%@",mostRecentLogFile];
        NSArray *logFileAttachment = [NSArray arrayWithObjects:
                                      @"-F", logFile,
                                      nil];

        [args addObjectsFromArray:logFileAttachment];
    }
    
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
