//
//  PreferenceController.m
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PreferenceController.h"
#import "pipetest.h"

@implementation PreferenceController

- (id)init 
{
    if (![super initWithWindowNibName:@"Preferences"])
        return nil;
    return self;
}


- (void)awakeFromNib
{	
    NSLog(@"Nib file is loaded");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    BOOL val = [defaults boolForKey:@"yccheck"];
    
    //NSString *binary = @"/bin/sh";
   // NSArray *arguments = [NSArray arrayWithObjects: @"/Users/hr/Dropbox/get_dropbox_folder.sh",nil];
    
    // NSString *dropboxURL = systemCall(binary, arguments);
    
    char* shellFile = "/Users/hr/Dropbox/get_dropbox_folder.sh";
    
    char *out, *err;
    int outlen,errlen;
    
    NSString *dropboxURL;
    NSString *dropboxDefault = [defaults objectForKey:@"ycdropbox"];
    
    if(dropboxDefault == nil) {
        if(run_command(shellFile, &out, &outlen, &err, &errlen))
            NSLog(@"fail");
        else {
            dropboxURL = [NSString stringWithFormat:@"%s",out];
            dropboxURL = [dropboxURL stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            NSLog(@"new: [%@] ",dropboxURL);
        }
    }
    else {
        dropboxURL = dropboxDefault;
    }
                              
    int state;
    state = val?1:0;
   
    NSURL *url = [NSURL URLWithString:((NSString*)dropboxURL)];
    
    [checkbox setState:state];
    [dbLocation setURL:url];
    
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
    NSLog(@"Window closing!! .. changed? %d",changed);
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
    
    NSLog(@"Writing %d",stateBool);
    
    NSURL *dropboxURL = [dbLocation URL];
    [defaults setObject:[dropboxURL absoluteString] forKey:@"ycdropbox"];
    [defaults setBool:stateBool forKey:@"yccheck"];
    [defaults synchronize];
    
    NSLog(@"Checkbox changed %d", state);
    
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
        NSLog(@"No path selected, return..."); 
        return; 
    }
   // NSURL *url = [NSURL URLWithString:((NSString*)[path objectAtIndex:0])];
    NSURL *url = [path objectAtIndex:0];
    [dbLocation setURL:url];

}

@end
