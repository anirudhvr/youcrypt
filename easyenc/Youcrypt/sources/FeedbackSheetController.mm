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
#import "AppDelegate.h"
#import "DDFileLogger.h"
#import "LFCGzipUtility.h"
#import "core/Settings.h"

@interface FeedbackSheetController ()

@end

@implementation FeedbackSheetController

@synthesize message;
@synthesize textView;
@synthesize anonymize;
@synthesize logfiles;
@synthesize emailCopy;
@synthesize progressMessage;
@synthesize isBug;
@synthesize isFeature;
@synthesize isSuggestion;

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
    [textView setString:@""];
    [progressMessage setStringValue:@""];
}

-(IBAction)send:(id)sender
{
    (void)sender;
    NSString *curlEmail, *copyEmail = @"";
   
    NSString *userRealName = [theApp.preferenceController getPreference:(MacUISettings::MacPreferenceKeys::yc_userrealname)];
    NSString *userEmail = [theApp.preferenceController getPreference:(MacUISettings::MacPreferenceKeys::yc_useremail)];
    
    if([anonymize state]) {
        curlEmail = [NSString stringWithFormat:@"from=\"anonymous@youcrypt.com\""];
    }
    else {
        if (![libFunctions validateEmail:userEmail])
            userEmail = @"invalid-email@youcrypt.com";
        
        curlEmail = [NSString stringWithFormat:@"from=\"%@ <%@>\"",userRealName,userEmail];
    }
    
    
    
    NSString *subject = @"subject='";
    if ([isBug state])
        subject = [subject stringByAppendingString:@"[Bug] "];
    if ([isFeature state])
        subject = [subject stringByAppendingString:@"[Feature] "];
    if ([isSuggestion state])
        subject = [subject stringByAppendingString:@"[Suggestion] "];
    
    subject = [subject stringByAppendingString:@"YouCrypt Feedback'"];

    
    
    NSString *curlText   = [NSString stringWithFormat:@"text=%@", [textView string]];
    NSString *compressedLogFile;
    
    NSMutableArray *args = [NSMutableArray arrayWithObjects: 
                     @"-s", @"-k",
                     @"--user", YC_MAILGUN_API_KEY,
                     YC_MAILGUN_URL,
                     @"-F", curlEmail,
                     @"-F", @"to=\"feedback@youcrypt.com\"",
                     @"-F", subject,
                     @"-F", curlText, 
            nil];
    
    if ([emailCopy state]) {
        copyEmail = [NSString stringWithFormat:@"bcc=\"%@\"",userEmail];
        [args addObject:@"-F"];
        [args addObject:copyEmail];
    }
    
    if([logfiles state]) {
        // Include most recent log file.
        
        NSString *mostRecentLogFile = [[logFileManager sortedLogFilePaths] objectAtIndex:0];
        NSString *logFile;
        logFile = [NSString stringWithFormat:@"attachment=@%@",mostRecentLogFile];
        NSData *logFileData = [[NSData alloc] initWithContentsOfFile:mostRecentLogFile];
        NSData *compressedLogFileData = [[NSData alloc] initWithData:[LFCGzipUtility gzipData:logFileData]];
        compressedLogFile = [NSString stringWithFormat:@"%@/logFile.gz",
                             nsstrFromCpp(appSettings()->logDirectory.string())];
       // DDLogInfo(@"Compressed log file : %@",compressedLogFile);
        BOOL wrote = [compressedLogFileData writeToFile:compressedLogFile atomically:YES];
        if(wrote) {
        //    DDLogInfo(@"Compressed!");
            logFile = [NSString stringWithFormat:@"attachment=@%@",compressedLogFile];
        }
        NSArray *logFileAttachment = [NSArray arrayWithObjects:
                                      @"-F", logFile,
                                      nil];
        [args addObjectsFromArray:logFileAttachment];
    }
    
    NSFileHandle *fh = [NSFileHandle alloc];
    NSString *reply;
    NSTask *feedbackTask = [NSTask alloc];
    
    BOOL ret = [libFunctions execWithSocket:@"/usr/bin/curl" arguments:args env:nil io:fh proc:feedbackTask];
    if (ret) {
        [feedbackTask waitUntilExit];
        NSData *bytes = [fh availableData];
        reply = [[NSString alloc] initWithData:bytes encoding:NSUTF8StringEncoding];
        
        [fh closeFile];
        
        [progressMessage setStringValue:@"Email sent to feedback@youcrypt.com. Thanks!"];
        [progressMessage display];
        [NSThread sleepForTimeInterval:1.0f];
        
    } else {
        
        [progressMessage setStringValue:@"Error. curl not installed?"];
        DDLogInfo(@"Sending feedback failed");
        [progressMessage display];
        [NSThread sleepForTimeInterval:1.5f];
    }
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:compressedLogFile error:&error];
    
    
    [textView setString:@""];
    [progressMessage setStringValue:@""];
    
    [self.window close];
}

-(IBAction)cancel:(id)sender
{
    [textView setString:@""];
    [progressMessage setStringValue:@""];
    [self.window close];
}

@end
