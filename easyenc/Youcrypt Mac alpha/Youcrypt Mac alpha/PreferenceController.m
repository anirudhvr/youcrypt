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

@implementation PreferenceController

@synthesize client = _client;
@synthesize boxClient;


- (id)init 
{
    if (![super initWithWindowNibName:@"Preferences"])
        return nil;
    return self;
}


- (void)awakeFromNib
{	
    boxClient = [[BoxFSA alloc] init];
    DDLogVerbose(@"Nib file is loaded");

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"ycdropbox"];
    
    BOOL val = [defaults boolForKey:@"yccheck"];
    
     
    //NSString *binary = @"/bin/sh";
   // NSArray *arguments = [NSArray arrayWithObjects: @"/Users/hr/Dropbox/get_dropbox_folder.sh",nil];
    
    // NSString *dropboxURL = systemCall(binary, arguments);
    
    char *shellFile = "/Users/hr/Dropbox/get_dropbox_folder.sh";
    char *out, *err;
    int outlen,errlen;
    
    NSString *dropboxURL;
    NSString *dropboxDefault = [defaults objectForKey:@"ycdropbox"];
    
    if(dropboxDefault == nil) {
        if(run_command(shellFile, &out, &outlen, &err, &errlen)) {
            DDLogVerbose(@"fail");
            dropboxURL = NSHomeDirectory();
        } else {
            dropboxURL = [NSString stringWithFormat:@"%s",out];
            dropboxURL = [dropboxURL stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            DDLogVerbose(@"new: [%@] ",dropboxURL);
        }
    }
    else {
        dropboxURL = dropboxDefault;
    }
                    
    if([defaults objectForKey:@"ycbox"] == nil) {
        [boxLinkStatus setTextColor:[NSColor redColor]];
        [boxLinkStatus setStringValue:@"Unlinked"];

    } else {
        [linkBox setTitle:@"Unlink"];
        [boxLinkStatus setTextColor:[NSColor greenColor]];
        [boxLinkStatus setStringValue:@"Linked"];
    }
    int state;
    state = val?1:0;
   
    NSURL *url = [NSURL URLWithString:((NSString*)dropboxURL)];
    
    [dbLocation setHidden:NO];
    
    [checkbox setState:state];
    [dbLocation setURL:url];
   
    //[self sendEmail];
    
    NSString *reqURL = [NSString stringWithFormat:@"https://www.box.com/api/1.0/rest?action=get_ticket&api_key=%@",@"az9ug6vjgygca8qbf3x3txldhoro5jbr"];
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:reqURL]];
	NSURLResponse *resp = nil;
	NSError *error = nil;
	NSData *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &error];
	NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]; 

    NSLog(@"%@",responseString);
    
    NSLog(@"Testing sparkle");
}

-(void)refreshBoxLinkStatus:(BOOL)linked
{
    if(linked){
        [linkBox setTitle:@"Unlink"];
        [boxLinkStatus setTextColor:[NSColor greenColor]];
        [boxLinkStatus setStringValue:@"Linked"];
    }
    else {
        [linkBox setTitle:@"Link"];
        [boxLinkStatus setTextColor:[NSColor redColor]];
        [boxLinkStatus setStringValue:@"Unlinked"];
    }

}

-(IBAction)linkBoxAccount:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"ycbox"] == nil) {
        [boxClient auth];
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"When You have authorized us, please click OK."];
        [alert setInformativeText:@"Please do not click OK before logging into Box."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(boxAuthDone:returnCode:) contextInfo:nil];
    }
    else {
        [defaults setObject:nil forKey:@"ycbox"];
        [self refreshBoxLinkStatus:NO];
    }
    
}

-(void)sendEmail
{
    char *shellFile = "/Users/hr/simple-mailer.py --tls hrbaconbits@gmail.com:Nouvou123@smtp.gmail.com:587 hardik988@gmail.com hardik988@gmail.com \"Hello WOrld\"";
    char *out, *err;
    int outlen,errlen;
    run_command(shellFile, &out, &outlen, &err, &errlen);

}

-(void)boxAuthDone:(NSAlert *)alert returnCode:(NSInteger)returnCode
{
    [self sendEmail];
    [boxClient userGavePerms];
    [self refreshBoxLinkStatus:YES];
}

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
- (BOOL)windowShouldClose:(id)sender
{
    DDLogVerbose(@"Window closing!! .. changed? %d",changed);
    if(!changed){
        return YES;
    }
    else {
        return NO;
    }
}

- (IBAction)saveButton:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int state = [checkbox state];
    BOOL stateBool;
    if(state)
        stateBool = YES;
    else stateBool = NO;
    
    DDLogVerbose(@"Writing %d",stateBool);
    
    NSURL *dropboxURL = [dbLocation URL];
    [defaults setObject:[dropboxURL absoluteString] forKey:@"ycdropbox"];
    [defaults setBool:stateBool forKey:@"yccheck"];
    [defaults synchronize];
    
    DDLogVerbose(@"Checkbox changed %d", state);
    
    changed = NO;
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
    [dbLocation setURL:url];

}

@end
