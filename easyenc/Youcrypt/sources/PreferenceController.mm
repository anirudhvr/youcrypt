//
//  PreferenceController.m
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PreferenceController.h"
#import "PassphraseSheetController.h"
#import "GmailSheetController.h"
#import "FirstRunSheetController.h"
#import <StartOnLogin/StartOnLogin.h>
#import "libFunctions.h"
#import "XMLDictionary.h"
#import "core/DirectoryMap.h"

@implementation PreferenceController

@synthesize boxClient;
@synthesize passphraseSheetController;
@synthesize gmailSheetController;
@synthesize changePassphraseButton;
@synthesize firstRunSheetController;

- (id)init 
{
    if (![super initWithWindowNibName:@"Preferences"])
        return nil;
    
    /* initializing some arrays */
    boxClient = [[BoxFSA alloc] init];

    startOnLogin = [[StartOnLogin alloc] init];
    preferences = [[NSMutableDictionary alloc] init];
    passphraseSheetController = [[PassphraseSheetController alloc] init];
    gmailSheetController = [[GmailSheetController alloc] init];
    firstRunSheetController = [[FirstRunSheetController alloc] init];
    [self readPreferences];
    return self;
}

- (id)getPreference:(NSString*)key
{
    return [preferences objectForKey:key];
}

- (void)setPreference:(NSString*)key value:(id)val
{
//    NSLog(@"setPref %@ %@",key,val);
    [preferences setObject:val forKey:key];
}

- (void)removePreference:(NSString*)key
{
    [preferences removeObjectForKey:key];
}

- (void) readPreferences
{
    /**
     * Set up default prefs
     */
    preferencesKeys = [NSArray arrayWithObjects:
                       YC_DROPBOXLOCATION, 
                       YC_BOXLOCATION, 
                       YC_ENCRYPTFILENAMES, 
                       YC_STARTONBOOT,  
                       YC_ANONYMOUSSTATISTICS, 
                       YC_IDLETIME, 
                       YC_USERREALNAME, 
                       YC_USEREMAIL, 
                       YC_GMAILUSERNAME, 
                       YC_BOXSTATUS, 
                       nil];
    
    defaultPreferences = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:
                                                                       [libFunctions locateDropboxFolder], 
                                                                       [self locateBoxFolder], 
                                                                       [NSNumber numberWithInt:0], 
                                                                       [NSNumber numberWithInt:1], 
                                                                       [NSNumber numberWithInt:1], 
                                                                       @"",
                                                                       @"", 
                                                                       @"", 
                                                                       @"", 
                                                                       @"", 
                                                                       nil] 
                                                              forKeys:preferencesKeys];

    //    NSLog(@"Reading stored preferences");
    NSString *prefValue;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (NSString *prefKey in preferencesKeys) {
        prefValue = [defaults stringForKey:prefKey];
        
        if(prefValue == nil){
            [preferences setValue:[defaultPreferences objectForKey:prefKey] forKey:prefKey];
            DDLogVerbose(@"WARNING: Setting %@ %@ was Nil in Defaults",prefKey,[defaultPreferences objectForKey:prefKey]);
            
        }
        else{
            [preferences setValue:prefValue forKey:prefKey];
        }
    }
}

- (void) savePreferences
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValuesForKeysWithDictionary:preferences];
    //   NSLog(@"SAVING:  %@",preferences);
    [defaults synchronize];
}


- (void)awakeFromNib
{	
    

    /**
     * Set UI values to match prefs read from NSUserDEfaults
     */
    [startOnBoot setState:[[self getPreference:YC_STARTONBOOT] intValue]];
    [enableFilenameEncryption setState:[[self getPreference:YC_ENCRYPTFILENAMES] intValue]];
    [allowAnonymousUsageStatistics setState:[[self getPreference:YC_ANONYMOUSSTATISTICS] intValue]];
    [idleTime setStringValue:[self getPreference:YC_IDLETIME]];
    
    
    [realName setStringValue:[self getPreference:YC_USERREALNAME]];
    [email setStringValue:[self getPreference:YC_USEREMAIL]];
    [passphrase setStringValue:@"somerandomvalue"];
    [passphrase setEditable:NO];
    
    
//    if([self getPreference:YC_USERREALNAME] == nil)
//        NSLog(@"NIL!");

    passphraseSheetController = [[PassphraseSheetController alloc] init];
    
    [tabView selectTabViewItem:[tabView tabViewItemAtIndex:0]];
    
//    NSLog(@"email, name : %@ %@ %@",[self getPreference:YC_USEREMAIL],[self getPreference:YC_USERREALNAME],@"");
//    NSLog(@"dbloc aw; %@",[self getPreference:YC_DROPBOXLOCATION]);
//    
    if([self getPreference:YC_DROPBOXLOCATION] == nil){
        [dropboxLocation setHidden:YES];
    } else {
        [dropboxLocation setHidden:NO];
        [dropboxLocation setURL:[NSURL URLWithString:[self getPreference:YC_DROPBOXLOCATION]]];
    }
    
    if(([self getPreference:YC_BOXSTATUS] == nil) ||([[self getPreference:YC_BOXSTATUS] isEqualToString:@""])) {
        [linkBox setTitle:@"Link Box Account"];
        [boxLocation setHidden:YES];
        
    } else {
        DDLogInfo(@"box loc valid : %@",[self getPreference:YC_BOXLOCATION]);
        [boxLocation setHidden:NO];
        [boxLocation setURL:[NSURL URLWithString:[self getPreference:YC_BOXLOCATION]]];
        [linkBox setTitle:@"Unlink Box Account"];
    }
    
    if(([self getPreference:YC_GMAILUSERNAME] == nil) || [self getPreference:YC_GMAILUSERNAME] == @"") {
        [linkGmail setTitle:@"Set GMail Credentials"];

    } else {
        DDLogInfo(@"gmail username valid : %@",[self getPreference:YC_GMAILUSERNAME]);
        [linkGmail setTitle:@"Change GMail Credentials"];
    }
    
    NSImage *dbLogo = [[NSImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"/DropBox.png"]];
    NSImage *boxLogo = [[NSImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"/box-logo.png"]];
    [dbIcon setImage:dbLogo];
    [boxIcon setImage:boxLogo];
}

                    
-(void)refreshBoxLinkStatus:(BOOL)linked
{
    if(linked){
        [linkBox setTitle:@"Unlink Box Account"];
    }
    else {
        [linkBox setTitle:@"Link Box Account"];
    }

}

-(NSString*)locateBoxFolder
{
    NSString *boxXMLPath = [NSString stringWithFormat:@"%@/Library/Application Support/Box Sync/LastLoggedInUserInfo.xml",NSHomeDirectory()];
    NSDictionary *xmlDoc = [NSDictionary dictionaryWithXMLFile:boxXMLPath];
    NSString *boxFolderPath = [[xmlDoc objectForKey:@"Settings"] objectForKey:@"_RootSyncFolderLocation"];
    //DDLogVerbose(@"Box folder loc : %@",boxFolderPath);
    if (boxFolderPath == nil)
        boxFolderPath = @"";
    return boxFolderPath;
}

-(IBAction)linkBoxAccount:(id)sender
{
    (void)sender;
    DDLogVerbose(@"box status: %@",[self getPreference:YC_BOXSTATUS]);
    if(([self getPreference:YC_BOXSTATUS] == nil) || ([[self getPreference:YC_BOXSTATUS] isEqualToString:@""]) ) {
        [boxClient auth];
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:@"After logging in and authorizing with Box, please click OK."];
        [alert setInformativeText:@"If you do not wish to continue, please click Cancel."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(boxAuthDone:returnCode:) contextInfo:nil];
    }
    else {
        DDLogVerbose(@"removing boxstatus pref");
        //[self removePreference:YC_BOXSTATUS];
        [self setPreference:YC_BOXSTATUS value:@""];
        [self refreshBoxLinkStatus:NO];
    }
}

-(IBAction)linkGmailAccount:(id)sender
{
    (void)sender;
        gmailSheetController.preferenceController = self;
        [gmailSheetController beginSheetModalForWindow:self.window completionHandler:^(NSUInteger returnCode) {
            if (returnCode == kSheetReturnedSave) {
                DDLogVerbose(@"linkGmailAccount: Gmail password saved");
                [self refreshGmailLinkStatus:YES];
            } else if (returnCode == kSheetReturnedCancel) {
                DDLogVerbose(@"linkGmailAccount: Gmail password cancelled");
            } else {
                DDLogVerbose(@"linkGmailAccount: Unknown return code");
            }
        }];

}

-(void)refreshGmailLinkStatus:(BOOL)linked
{
    if(linked){
        [linkGmail setTitle:@"Change GMail Credentials"];
    }
    else {
        [linkGmail setTitle:@"Set GMail Credentials"];
    }
}

-(void)sendEmail
{
//    char *shellFile = "/Users/hr/simple-mailer.py --tls hrbaconbits@gmail.com:Nouvou123@smtp.gmail.com:587 hardik988@gmail.com hardik988@gmail.com \"Hello WOrld\"";
//    char *out, *err;
//    int outlen,errlen;
//    run_command(shellFile, &out, &outlen, &err, &errlen);
//    FIXME
}

-(void)boxAuthDone:(NSAlert *)alert returnCode:(NSInteger)returnCode
{
    (void)alert;
    if (returnCode == NSAlertFirstButtonReturn) {
        DDLogVerbose(@"BOX AUTH DONE!");
        //[self sendEmail];
        NSString *boxAuthToken = [boxClient userGavePerms];
        if(![boxAuthToken isEqualToString:@""]) {
            [self setPreference:YC_BOXSTATUS value:boxAuthToken];
            [self refreshBoxLinkStatus:YES];    
        }
    }
}

-(IBAction)windowDidLoad:(id)sender
{
    (void)sender;
//    NSLog(@"Windowdidload called");
}

-(IBAction)windowWillLoad:(id)sender
{
    (void)sender;
//    NSLog(@"Windowwillload called");
}



- (BOOL)windowShouldClose:(id)sender
{
    (void)sender;
    
    [self setPreference:YC_USERREALNAME value:[realName stringValue]];
    [self setPreference:YC_USEREMAIL value:[email stringValue]];
    //[self setPreference:YC_BOXLOCATION value:[[boxLocation URL] absoluteString]];
    //[self setPreference:YC_DROPBOXLOCATION value:[[dropboxLocation URL] absoluteString]];
    [self savePreferences];
    
   // [self close];
    // This should be set each tiem the window loads, but I have 
    // no idea what function is called each time the window is loaded
    [tabView selectTabViewItem:[tabView tabViewItemAtIndex:0]];

    return YES;
}

-(IBAction)changePassphrase:(id)sender
{
    (void)sender;
    DirectoryMap &dmap = getDirectories();

    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (auto d: dmap) {
        [arr addObject:[NSString stringWithCString:d.first.c_str()
                                          encoding:NSASCIIStringEncoding]];
    }
    passphraseSheetController.arr = arr;
    [passphraseSheetController beginSheetModalForWindow:self.window completionHandler:^(NSUInteger returnCode) {
        if (returnCode == kSheetReturnedSave) {
            DDLogVerbose(@"changePassphrase: Passphrase change saved");
        } else if (returnCode == kSheetReturnedCancel) {
            DDLogVerbose(@"changePassphrase: Passphrase change cancelled");
        } else {
            DDLogVerbose(@"changePassphrase: Unknown return code");
        }
    }];
}


-(void)showFirstRun
{
    [tabView selectTabViewItem:[tabView tabViewItemAtIndex:1]];

    [firstRunSheetController beginSheetModalForWindow:self.window completionHandler:^(NSUInteger returnCode) {
        if (returnCode == kSheetReturnedSave) {
            DDLogVerbose(@"showFirstRun: First run done");
            [self.window close];
        } else if (returnCode == kSheetReturnedCancel) {
            DDLogVerbose(@"showFirstRun: First Run cancelled :( ");
        } else {
            DDLogVerbose(@"showFirstRun: Unknown return code");
        }
    }];

}


static NSArray *openFiles()
{ 
    NSOpenPanel *panel;
    
    panel = [NSOpenPanel openPanel];        
    [panel setFloatingPanel:YES];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
	long i = [panel runModal];
	if(i == NSOKButton){
		return [panel URLs];
    }
    
    return nil;
}   

- (IBAction)chooseDBLocation:(id)sender
{
    (void)sender;
    NSArray *path = openFiles();
    
    if(!path){ 
        DDLogVerbose(@"No path selected, return..."); 
        return; 
    }
    NSURL *url = [path objectAtIndex:0];
    [dropboxLocation setURL:url];

}

- (IBAction)chooseBoxLocation:(id)sender
{
    (void)sender;
    NSArray *path = openFiles();
    
    if(!path){ 
        DDLogVerbose(@"No path selected, return..."); 
        return; 
    }
    NSURL *url = [path objectAtIndex:0];
    [boxLocation setURL:url];

}
- (IBAction)filenameEncryptionChecked:(id)sender
{
    (void)sender;
    long encState = [enableFilenameEncryption state];
    if (encState != [[preferences objectForKey:YC_ENCRYPTFILENAMES] intValue]) {
        // NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:encState], YC_ENCRYPTFILENAMES, nil];
        DDLogVerbose(@"updating encstate to %ld", encState);
        [self setPreference:YC_ENCRYPTFILENAMES value:[NSNumber numberWithLong:encState]];
    }
}

- (IBAction)startOnBootChecked:(id)sender
{
    (void)sender;
    long onBootState = [startOnBoot state];
  //  NSLog(@"checkbox state: %d, stored state: %d", onBootState, [[preferences objectForKey:YC_STARTONBOOT] intValue]);
    if (onBootState != [[preferences objectForKey:YC_STARTONBOOT] intValue]) {
       // NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:onBootState], YC_STARTONBOOT, nil];
        [self setPreference:YC_STARTONBOOT value:[NSNumber numberWithLong:onBootState]];
     //   DDLogVerbose(@"Setting onboot state to %d", onBootState);
     //   NSLog(@"Stored prefs state: %d", [[self getPreference:YC_STARTONBOOT] intValue]);
        if (onBootState == NSOnState) {
            DDLogInfo(@"Will start at login");
            [StartOnLogin setStartAtLogin:[self appURL] enabled:YES];
        } else {
            DDLogInfo(@"Will not start at login");
            [StartOnLogin setStartAtLogin:[self appURL] enabled:NO];
        }
    }
}

- (IBAction)allowAnonymousUsageStatisticsChecked:(id)sender
{
    (void)sender;
    long state = [allowAnonymousUsageStatistics state];
    if (state != [[self getPreference:YC_ANONYMOUSSTATISTICS] intValue]) {
        DDLogInfo(@"old anonym feedback checkbox state: %ld, new: %d", state, [[self getPreference:YC_ANONYMOUSSTATISTICS] intValue]);
        [self setPreference:YC_ANONYMOUSSTATISTICS value:[NSNumber numberWithLong:state]];
    }
}

- (IBAction)idleTimeChanged:(id)sender
{
    (void)sender;
    DDLogInfo(@"idle time changed to %@", [idleTime stringValue]);
    [self setPreference:YC_IDLETIME value:[idleTime stringValue]];
}

- (NSURL *)appURL
{
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
}

@end
