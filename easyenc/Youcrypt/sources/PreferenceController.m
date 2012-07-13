//
//  PreferenceController.m
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PreferenceController.h"
#import "Contrib/Lumberjack/logging.h"
#import "PassphraseSheetController.h"
#import "GmailSheetController.h"
#import "FirstRunSheetController.h"
#import <StartOnLogin/StartOnLogin.h>
#import "libFunctions.h"
#import "XMLDictionary.h"
#import "AppDelegate.h"
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
    return self;
}

- (void)updatePreferences:(NSDictionary*)prefs
{
    for (NSString *key in prefs) {
        if ([key isEqualToString:YC_STARTONBOOT]) {
            [startOnBoot setState:[[prefs objectForKey:YC_STARTONBOOT] intValue]];
        } else if ([key isEqualToString:YC_ENCRYPTFILENAMES]) {
            [enableFilenameEncryption setState:[[prefs objectForKey:YC_ENCRYPTFILENAMES] intValue]];
        } else if ([key isEqualToString:YC_DROPBOXLOCATION]) {
            [dropboxLocation setStringValue:[prefs objectForKey:YC_DROPBOXLOCATION]];
        } else if ([key isEqualToString:YC_BOXLOCATION]) {
            [boxLocation setStringValue:[prefs objectForKey:YC_BOXLOCATION]];
        } else if ([key isEqualToString:YC_USERREALNAME]) {
            [realName setStringValue:[prefs objectForKey:YC_USERREALNAME]];
        } else if ([key isEqualToString:YC_USEREMAIL]) {
            [email setStringValue:[prefs objectForKey:YC_USEREMAIL]];
        } else {
            //DDLogError(@"key %@ not a valid preference", key);
        }
    }   
}

- (id)getPreference:(NSString*)key
{
    return [preferences objectForKey:key];
}

- (void)setPreference:(NSString*)key value:(id)val
{
    NSLog(@"setPref %@ %@",key,val);
    [preferences setObject:val forKey:key];
}

- (void)removePreference:(NSString*)key
{
    [preferences removeObjectForKey:key];
}

- (void)awakeFromNib
{	
    preferencesKeys = [NSArray arrayWithObjects:YC_DROPBOXLOCATION, 
                       YC_BOXLOCATION, YC_ENCRYPTFILENAMES, YC_STARTONBOOT, 
                       YC_USERREALNAME, YC_USEREMAIL, YC_GMAILUSERNAME, YC_BOXSTATUS, nil];

    defaultPreferences = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[libFunctions locateDropboxFolder], [self locateBoxFolder], [NSNumber numberWithInt:1], [NSNumber numberWithInt:1], @"", @"", @"", @"", nil] forKeys:preferencesKeys];
    
    NSLog(@"%@",defaultPreferences);
    
    
    DDLogVerbose(@"Preferences awakeFromNib called");
  
     // load preferences from NSUserDefaults
    [self readPreferences];
    //[preferences addEntriesFromDictionary:defaultPreferences];

    
    NSLog(@"%@",preferences);

    //[self updatePreferences:preferences];
    
    [realName setStringValue:[self getPreference:YC_USERREALNAME]];
    [email setStringValue:[self getPreference:YC_USEREMAIL]];
    [passphrase setStringValue:@"somerandomvalue"];
    [passphrase setEditable:NO];
    if([self getPreference:YC_USERREALNAME] == nil)
        NSLog(@"NIL!");

    passphraseSheetController = [[PassphraseSheetController alloc] init];
    
    [tabView selectTabViewItem:[tabView tabViewItemAtIndex:0]];
    
    NSLog(@"%@ %@ %@",[self getPreference:YC_USEREMAIL],[self getPreference:YC_USERREALNAME],@"");
    NSLog(@"dbloc aw; %@",[self getPreference:YC_DROPBOXLOCATION]);
    
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
        NSLog(@"box loc valid : %@",[self getPreference:YC_BOXLOCATION]);
        [boxLocation setHidden:NO];
        [boxLocation setURL:[NSURL URLWithString:[self getPreference:YC_BOXLOCATION]]];
        [linkBox setTitle:@"Unlink Box Account"];
    }
    
    if(([self getPreference:YC_GMAILUSERNAME] == nil) || [self getPreference:YC_GMAILUSERNAME] == @"") {
        [linkGmail setTitle:@"Set GMail Credentials"];

    } else {
        NSLog(@"gmail username valid : %@",[self getPreference:YC_GMAILUSERNAME]);
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
    NSLog(@"Box folder loc : %@",boxFolderPath);
    if (boxFolderPath == nil)
        boxFolderPath = [[NSString alloc] initWithString:@""];
    return boxFolderPath;
}

-(IBAction)linkBoxAccount:(id)sender
{
    NSLog(@"%@",[self getPreference:YC_BOXSTATUS]);
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
        NSLog(@"removing boxstatus pref");
        //[self removePreference:YC_BOXSTATUS];
        [self setPreference:YC_BOXSTATUS value:@""];
        [self refreshBoxLinkStatus:NO];
    }
}

-(IBAction)linkGmailAccount:(id)sender
{
        gmailSheetController.preferenceController = self;
        [gmailSheetController beginSheetModalForWindow:self.window completionHandler:^(NSUInteger returnCode) {
            if (returnCode == kSheetReturnedSave) {
                NSLog(@"Gmail password saved");
                [self refreshGmailLinkStatus:YES];
            } else if (returnCode == kSheetReturnedCancel) {
                NSLog(@"Gmail password cancelled");
            } else {
                NSLog(@"Unknown return code");
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
    char *shellFile = "/Users/hr/simple-mailer.py --tls hrbaconbits@gmail.com:Nouvou123@smtp.gmail.com:587 hardik988@gmail.com hardik988@gmail.com \"Hello WOrld\"";
    char *out, *err;
    int outlen,errlen;
//    run_command(shellFile, &out, &outlen, &err, &errlen);
//    FIXME
}

-(void)boxAuthDone:(NSAlert *)alert returnCode:(NSInteger)returnCode
{
    if (returnCode == NSAlertFirstButtonReturn) {
        NSLog(@"BOX AUTH DONE!");
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
    NSLog(@"Windowdidload called");
}

-(IBAction)windowWillLoad:(id)sender
{
    NSLog(@"Windowwillload called");
}

- (void) readPreferences
{ 
    NSLog(@"Reading stored preferences");
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
    NSLog(@"SAVING:  %@",preferences);
    [defaults synchronize];
}




- (BOOL)windowShouldClose:(id)sender
{
    DDLogVerbose(@"Window closing");
    
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
    NSLog(@"ChangePassphrase clicked");
    passphraseSheetController.arr = theApp.directories;
    [passphraseSheetController beginSheetModalForWindow:self.window completionHandler:^(NSUInteger returnCode) {
        if (returnCode == kSheetReturnedSave) {
            NSLog(@"Passphrase change saved");
        } else if (returnCode == kSheetReturnedCancel) {
            NSLog(@"Passphrase change cancelled");
        } else {
            NSLog(@"Unknown return code");
        }
    }];
}


-(void)showFirstRun
{
    [tabView selectTabViewItem:[tabView tabViewItemAtIndex:1]];

    [firstRunSheetController beginSheetModalForWindow:self.window completionHandler:^(NSUInteger returnCode) {
        if (returnCode == kSheetReturnedSave) {
            NSLog(@"First run done");
            [self.window close];
        } else if (returnCode == kSheetReturnedCancel) {
            NSLog(@"First Run cancelled :( ");
        } else {
            NSLog(@"Unknown return code");
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
	int i = [panel runModal];
	if(i == NSOKButton){
		return [panel URLs];
    }
    
    return nil;
}   

- (IBAction)chooseDBLocation:(id)sender
{   
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
    int encState = [enableFilenameEncryption state];
    if (encState != [[preferences objectForKey:YC_ENCRYPTFILENAMES] intValue]) {
        // NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:encState], YC_ENCRYPTFILENAMES, nil];
        DDLogVerbose(@"updating encstate to %d", encState);
        //[self updatePreferences:dict];
        [self setPreference:YC_ENCRYPTFILENAMES value:[NSNumber numberWithInt:encState]];
    }
}

- (IBAction)startOnBootChecked:(id)sender
{
    int onBootState = [startOnBoot state];
  //  NSLog(@"checkbox state: %d, stored state: %d", onBootState, [[preferences objectForKey:YC_STARTONBOOT] intValue]);
    if (onBootState != [[preferences objectForKey:YC_STARTONBOOT] intValue]) {
       // NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:onBootState], YC_STARTONBOOT, nil];
        [self setPreference:YC_STARTONBOOT value:[NSNumber numberWithInt:onBootState]];
     //   DDLogVerbose(@"Setting onboot state to %d", onBootState);
       // [self updatePreferences:dict];
     //   NSLog(@"Stored prefs state: %d", [[self getPreference:YC_STARTONBOOT] intValue]);
        if (onBootState == NSOnState) {
            NSLog(@"Will start at login");
            [StartOnLogin setStartAtLogin:[self appURL] enabled:YES];
        } else {
            NSLog(@"Will not start at login");
            [StartOnLogin setStartAtLogin:[self appURL] enabled:NO];
        }
    }
}

- (IBAction)idleTimeChanged:(id)sender
{
    NSLog(@"idle time changed to %@", [idleTime stringValue]);
    [self setPreference:YC_IDLETIME value:[idleTime stringValue]];
}

- (NSURL *)appURL
{
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
}

@end
