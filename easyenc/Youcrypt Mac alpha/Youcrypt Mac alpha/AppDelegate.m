//
//  AppDelegate.m
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "PreferenceController.h"
#import "FileSystem.h"

@implementation AppDelegate

@synthesize window = _window;

- (id) init
{
    self = [super init];
    if(self){
        filesystems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}


-(void)awakeFromNib{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setTitle:@"YC"];
    [statusItem setHighlightMode:YES];
}

-(IBAction)windowShouldClose:(id)sender
{
    NSLog(@"Closing..");
}

-(IBAction)showMainApp:(id)sender
{
    [self.window makeKeyAndOrderFront:self];
}
- (IBAction)showPreferencePanel:(id)sender
{
    // Is preferenceController nil?
    if (!preferenceController) {
        preferenceController = [[PreferenceController alloc] init];
    }
    NSLog(@"showing %@", preferenceController);
    [preferenceController showWindow:self];
}

- (IBAction)terminateApp:(id)sender
{
    [NSApp terminate:nil];
}

- (void)setFilesystems:(NSMutableArray *)f
{
    // This is an unusual setter method.  We are going to add a lot
    // of smarts to it in the next chapter.
    if (f == filesystems)
        return;
    filesystems = f;
}


@end
