//
//  PreferenceController.m
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PreferenceController.h"
#import "pipetest.h"
#import "logging.h"
#import "PassphraseSheetController.h"
#import <StartOnLogin/StartOnLogin.h>

@implementation PreferenceController

@synthesize passphraseSheetController;
@synthesize changePassphraseButton;
- (id)init 
{
    if (![super initWithWindowNibName:@"Preferences"])
        return nil;
    
    /* initializing some arrays */
    preferencesKeys = [NSArray arrayWithObjects:YC_DROPBOXLOCATION, 
                       YC_BOXLOCATION, YC_ENCRYPTFILENAMES, YC_STARTONBOOT, 
                       YC_USERREALNAME, YC_USEREMAIL, nil];
    defaultPreferences = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[self locateDropboxFolder], [self locateBoxFolder], YES, YES, @"", @"", nil] forKeys:preferencesKeys];
    [preferences initWithDictionary:defaultPreferences];
    
    startOnLogin = [[StartOnLogin alloc] init];
    
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
    [preferences setObject:val forKey:key];
}

- (void)awakeFromNib
{	
    DDLogVerbose(@"Preferences awakeFromNib called");
  
     // load preferences from NSUserDefaults
    [self readPreferences];
    [self updatePreferences:preferences];
    
    [realName setStringValue:[self getPreference:YC_USERREALNAME]];
    [email setStringValue:[self getPreference:YC_USEREMAIL]];
    [passphrase setStringValue:@"somerandomvalue"];

    passphraseSheetController = [[PassphraseSheetController alloc] init];

    [tabView selectTabViewItem:[tabView tabViewItemAtIndex:0]];
    
/*    
    BOOL val = [defaults boolForKey:@"yccheck"];
    
    int state;
    state = val?1:0;
    
    NSURL *url = [NSURL URLWithString:((NSString*)dropboxURL)];
    
    [checkbox setState:state];
    [dbLocation setURL:url];
  */  
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    preferences = (NSMutableDictionary*) [defaults dictionaryRepresentation];
}

- (void) savePreferences
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValuesForKeysWithDictionary:preferences];
    [defaults synchronize];
}
- (NSString*) locateBoxFolder
{
    DDLogVerbose(@"Fixme -- replace with box script");
    return [NSString stringWithFormat:@"%@/Box", NSHomeDirectory()];
}

- (NSString*) locateDropboxFolder
{
    NSString *bundlepath =[[NSBundle mainBundle] resourcePath];
    NSString *dropboxScript = [bundlepath stringByAppendingPathComponent:@"/get_dropbox_folder.sh"]; 
    const char *shellFile = NULL;
    char *out = NULL, *err = NULL;
    int outlen, errlen;
    NSString *dropboxURL;
      
    // check if dropbox script exists and fail otherwise
    if (![[NSFileManager defaultManager] fileExistsAtPath:dropboxScript]) {
        DDLogVerbose(@"Cannot find dropbox locator script at %@", dropboxScript);
        return nil;
    }
    shellFile = [dropboxScript UTF8String];
    
    if(run_command(shellFile, &out, &outlen, &err, &errlen)) {
        DDLogVerbose(@"Could not run dropbox locator script");
        dropboxURL = [NSString stringWithFormat:@"%@/Dropbox", NSHomeDirectory()];
    } else {
        dropboxURL = [NSString stringWithFormat:@"%s",out];
        dropboxURL = [dropboxURL stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        DDLogVerbose(@"Found dropbox location: [%@] ", dropboxURL);
    }
    
    if (out) free(out);
    if (err) free(err);
    
    return dropboxURL;
}
/*
-(IBAction)changeSetting:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int state = [checkbox state];
    BOOL stateBool;
    if(state)
        stateBool = YES;
    else stateBool = NO;
    
    if(stateBool != [defaults boolForKey:@"yccheck"]){
        changed = YES;
    }
    else changed = NO;
}
*/
- (BOOL)windowShouldClose:(id)sender
{
    DDLogVerbose(@"Window closing");
    
    [self setPreference:YC_USERREALNAME value:[realName stringValue]];
    [self setPreference:YC_USEREMAIL value:[email stringValue]];
    
    [self savePreferences];
    
    // This should be set each tiem the window loads, but I have 
    // no idea what function is called each time the window is loaded
    [tabView selectTabViewItem:[tabView tabViewItemAtIndex:0]];

    return YES;
}

-(IBAction)changePassphrase:(id)sender
{
    NSLog(@"ChangePassphrase clicked");
    
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


- (IBAction)saveServicesPrefs:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int state = [checkbox state];
    BOOL stateBool;
    if(state)
        stateBool = YES;
    else stateBool = NO;
    
    DDLogVerbose(@"Writing %d",stateBool);
    
    NSURL *dropboxURL = [dropboxLocation URL];
    [defaults setObject:[dropboxURL absoluteString] forKey:@"ycdropbox"];
    [defaults setBool:stateBool forKey:@"yccheck"];
    [defaults synchronize];
    
    DDLogVerbose(@"Checkbox changed %d", state);
    
    [self close];
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

- (IBAction) chooseDBLocation:(id) sender;
{   
    NSArray *path = openFiles();
    
    if(!path){ 
        DDLogVerbose(@"No path selected, return..."); 
        return; 
    }
   // NSURL *url = [NSURL URLWithString:((NSString*)[path objectAtIndex:0])];
    NSURL *url = [path objectAtIndex:0];
    [dropboxLocation setURL:url];

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

- (NSURL *)appURL
{
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
}

@end
