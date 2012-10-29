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
#import <StartOnLogin/StartOnLogin.h>
#import "libFunctions.h"
#import "XMLDictionary.h"
#import "core/DirectoryMap.h"
#import "core/Settings.h"
#import "MacUISettings.h"
#import "AppDelegate.h"

@implementation PreferenceController

@synthesize boxClient;
@synthesize passphraseSheetController;
@synthesize gmailSheetController;
@synthesize changePassphraseButton;

typedef MacUISettings::MacPreferenceKeys ms;

- (id)init 
{
    if (!(self = [super initWithWindowNibName:@"Preferences"]))
        return nil;
    
    /* initializing some arrays */
    startOnLogin = [[StartOnLogin alloc] init];
    passphraseSheetController = [[PassphraseSheetController alloc] initWithPassphraseManager:[theApp passphraseManager]];
    
    return self;
}

- (NSString*)getPreference:(std::string)key
{
    return nsstrFromCpp((*appSettings())[key]);
}

- (NSString*)getPreferenceFromNSString:(NSString*)key
{
    return nsstrFromCpp((*appSettings())[cppString(key)]);
}

- (void)setPreferenceFromNSString:(NSString*)key value:(NSString*)val
{
    (*appSettings())[cppString(key)] = cppString((NSString*)val);
}

- (void)setPreference:(std::string)key value:(NSString*)val
{
    (*appSettings())[key] = cppString((NSString*)val);
}

- (void) savePreferences
{
    appSettings()->saveSettings();
}

- (void)awakeFromNib
{	
    /**
     * Set UI values to match prefs read from NSUserDefaults
     */
    [startOnBoot setState:[[self getPreference:(ms::yc_startonboot)] intValue]];
    [enableFilenameEncryption setState:[[self getPreference:(ms::yc_encryptfilenames)] intValue]];
    [allowAnonymousUsageStatistics setState:[[self getPreference:(ms::yc_anonymousstatistics)] intValue]];
    [idleTime setStringValue:[self getPreference:(ms::yc_idletime)]];
    
    
    [realName setStringValue:[self getPreference:(ms::yc_userrealname)]];
    [email setStringValue:[self getPreference:(ms::yc_useremail)]];
    
    [passphrase setStringValue:@"somerandomvalue"];
    [passphrase setEditable:NO];
    
    [tabView selectTabViewItem:[tabView tabViewItemAtIndex:0]];
    
    /* We don't show this tab currently */
    if([self getPreference:(ms::yc_dropboxlocation)] == nil){
        [dropboxLocation setHidden:YES];
    } else {
        [dropboxLocation setHidden:NO];
        [dropboxLocation setURL:[NSURL URLWithString:[self getPreference:(ms::yc_dropboxlocation)]]];
    }
    if(([self getPreference:(ms::yc_boxstatus)] == nil) ||([[self getPreference:(ms::yc_boxstatus)] isEqualToString:@""])) {
        [linkBox setTitle:@"Link Box Account"];
        [boxLocation setHidden:YES];
        
    } else {
        DDLogInfo(@"box loc valid : %@",[self getPreference:(ms::yc_boxlocation)]);
        [boxLocation setHidden:NO];
        [boxLocation setURL:[NSURL URLWithString:[self getPreference:(ms::yc_boxlocation)]]];
        [linkBox setTitle:@"Unlink Box Account"];
    }
    
    if(([self getPreference:(ms::yc_gmailusername)] == nil) || [self getPreference:(ms::yc_gmailusername)] == @"") {
        [linkGmail setTitle:@"Set GMail Credentials"];

    } else {
        DDLogInfo(@"gmail username valid : %@",[self getPreference:(ms::yc_gmailusername)]);
        [linkGmail setTitle:@"Change GMail Credentials"];
    }
    
    NSImage *dbLogo = [[NSImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"/DropBox.png"]];
    NSImage *boxLogo = [[NSImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"/box-logo.png"]];
    [dbIcon setImage:dbLogo];
    [boxIcon setImage:boxLogo];
}

///////////////////////////////////////
// Handlers for various controls on the
// Preferences windwo
///////////////////////////////////////

- (IBAction)filenameEncryptionChecked:(id)sender
{
    (void)sender;
    long encState = [enableFilenameEncryption state];
    if (encState != [nsstrFromCpp((*appSettings())[ms::yc_encryptfilenames]) intValue]) {
        DDLogVerbose(@"updating encstate to %ld", encState);
        [self setPreference:(ms::yc_encryptfilenames) value:[NSString stringWithFormat:@"%ld", encState]];
    }
}

- (IBAction)startOnBootChecked:(id)sender
{
    (void)sender;
    long onBootState = [startOnBoot state];
    if (onBootState != [nsstrFromCpp((*appSettings())[ms::yc_startonboot]) intValue]) {
        [self setPreference:(ms::yc_startonboot) value:[NSString stringWithFormat:@"%ld", onBootState]];
     //   DDLogVerbose(@"Setting onboot state to %d", onBootState);
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
    if (state != [[self getPreference:(ms::yc_anonymousstatistics)] intValue]) {
        DDLogInfo(@"old anonym feedback checkbox state: %ld, new: %d", state, [[self getPreference:(ms::yc_anonymousstatistics)] intValue]);
        [self setPreference:(ms::yc_anonymousstatistics) value:[NSString stringWithFormat:@"%ld", state]];
    }
}

- (IBAction)idleTimeChanged:(id)sender
{
    (void)sender;
    DDLogInfo(@"idle time changed to %@", [idleTime stringValue]);
    [self setPreference:(ms::yc_idletime) value:[idleTime stringValue]];
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
    NSLog(@"%lx %lx", [self window], [passphraseSheetController window]);
    [passphraseSheetController beginSheetModalForWindow:[self window] completionHandler:^(NSUInteger returnCode) {
        if (returnCode == kSheetReturnedSave) {
            DDLogVerbose(@"changePassphrase: Passphrase change saved");
        } else if (returnCode == kSheetReturnedCancel) {
            DDLogVerbose(@"changePassphrase: Passphrase change cancelled");
        } else {
            DDLogVerbose(@"changePassphrase: Unknown return code");
        }
    }];
}


///////////////////////////////////////
// Box linking / sharing code
///////////////////////////////////////
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
    DDLogVerbose(@"box status: %@",[self getPreference:(ms::yc_boxstatus)]);
    if(([self getPreference:(ms::yc_boxstatus)] == nil) || ([[self getPreference:(ms::yc_boxstatus)] isEqualToString:@""]) ) {
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
        [self setPreference:(ms::yc_boxstatus) value:@""];
        [self refreshBoxLinkStatus:NO];
    }
}

-(void)boxAuthDone:(NSAlert *)alert returnCode:(NSInteger)returnCode
{
    (void)alert;
    if (returnCode == NSAlertFirstButtonReturn) {
        DDLogVerbose(@"BOX AUTH DONE!");
        //[self sendEmail];
        NSString *boxAuthToken = [boxClient userGavePerms];
        if(![boxAuthToken isEqualToString:@""]) {
            [self setPreference:(ms::yc_boxstatus) value:boxAuthToken];
            [self refreshBoxLinkStatus:YES];    
        }
    }
}

///////////////////////////////////////
// Gmail linking / sharing code
///////////////////////////////////////
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
    
    [self setPreference:(ms::yc_userrealname) value:[realName stringValue]];
    [self setPreference:(ms::yc_useremail) value:[email stringValue]];
    [self savePreferences];
    
   // [self close];
    // This should be set each tiem the window loads, but I have 
    // no idea what function is called each time the window is loaded
    [tabView selectTabViewItem:[tabView tabViewItemAtIndex:0]];

    return YES;
}


////////////////////////////////
// Set Dropbox folder
/////////////////////////////////

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

////////////////////////////////
// Set Box folder
/////////////////////////////////

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

- (NSURL *)appURL
{
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
}

@end
